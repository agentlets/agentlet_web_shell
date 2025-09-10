import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/app_error.dart';
import 'package:wshell/shared/event_bus.dart';
import 'package:wshell/shared/llm/llm_model.dart';
import 'package:wshell/shared/llm/llm_model_error.dart';
import 'package:wshell/shared/llm/openai_model_proxy.dart';
import 'package:wshell/shared/logger.dart';

class LlmModels implements LlmModel {
  static final _ipapiUri = 'https://ipapi.co/json/';
  static final logger = WebLogger.createLogger(name: 'LlmModels');
  String _locationInfo = "Location info unavailable";
  bool _subscribedToEvents = false;

  LlmModels._privateConstructor() {
    _getLocationInfo().then((locationInfo) {
      _locationInfo = locationInfo;
    });
    // Complete the completer with the initial selected model
    _completableForGetCurrentSelectedModel.complete(_selectedModel);
  }
  static final LlmModels _instance = LlmModels._privateConstructor();

  factory LlmModels() {
    return _instance;
  }

  final LlmModel _selectedModel = OpenAIPModelProxy();

  LlmModel get selectedModel => _selectedModel;

  final Completer<LlmModel> _completableForGetCurrentSelectedModel =
      Completer<LlmModel>();

  Future<LlmModel> getCurrentSelectedModel() =>
      _completableForGetCurrentSelectedModel.future;

  @override
  String get id => selectedModel.id;

  @override
  String get name => selectedModel.name;

  @override
  String get provider => selectedModel.provider;

  void subscribeToEvents() async {
    if (_subscribedToEvents) return;

    GlobalEventBus.instance.on<MessageSent>().listen((event) async {
      logger.debug('LLM:${selectedModel.id}: mensaje recibido: ${event}');

      final TextLLMPrompt? behaviourPromptMessage = [
        event.behaviourPromptMessage
      ]
          .where((msg) => msg != null)
          .map((msg) => TextLLMPrompt(prompt: msg!.text, role: LLMRole.system))
          .firstOrNull;

      final List<ChatMessageBase> previousMessages =
          event.previousMessages.reversed.toList(growable: false);

      final List<LLMPromptBase> previousPrompts = previousMessages.map((msg) {
        if (msg is TextChatMessage) {
          return TextLLMPrompt(
              prompt: msg.text, role: LLMRole.fromName(msg.sender.name));
        } else if (msg is FunctionCallResponseMessage) {
          return FunctionCallResponseLLMPrompt(
              functionCallRequest: msg.functionCallRequest,
              response: msg.response);
        } else {
          throw ApplicationError(
              message:
                  'Unable to map previousPrompts. Unknown sender: ${msg.sender}');
        }
      }).toList();

      //define system prompt con la fecha y la geolocalizacion del usuario

      try {
        logger.debug('Trying to get current location...');
        //final LocationData pos = await determinarUbicacion();
        //logger.debug('Current location is ${pos.latitude},${pos.longitude}');

        final todayAndWhereAmISystemPrompt = TextLLMPrompt(prompt: '''
              Current DateTime is ${DateTime.now().toIso8601String()}.
              Current location info is $_locationInfo.
            ''', role: LLMRole.system);
        logger.debug(
            'System message for date and location: ${todayAndWhereAmISystemPrompt.toString()}');
        previousPrompts.add(todayAndWhereAmISystemPrompt);
      } catch (error) {
        logger.error('Unable to get current location: $error');
      }

      late final LLMPromptBase prompt;
      late final ChatMessageBase message;

      if (event.message is FunctionCallResponseMessage) {
        final FunctionCallResponseMessage msg =
            event.message as FunctionCallResponseMessage;
        message = msg;
        prompt = FunctionCallResponseLLMPrompt(
            functionCallRequest: msg.functionCallRequest,
            response: msg.response);
      } else if (event.message is TextChatMessage) {
        final TextChatMessage msg = event.message as TextChatMessage;
        message = msg;
        prompt = TextLLMPrompt(prompt: msg.text);
      } else {
        throw ApplicationError(
            message:
                'Unable to build prompt. Unknown messate type: ${event.message.runtimeType.toString()}');
      }

      try {
        final LLMResponse modelResponse = await this.sendPrompt(
            prompt: prompt,
            behaviourPromptMessage: behaviourPromptMessage,
            functions: event.functions,
            functionCall: 'auto',
            previousMessages: previousPrompts);

        if (modelResponse.type == LLMResponseType.text) {
          final TextLLMResponse textModelResponse =
              modelResponse as TextLLMResponse;

          final response = TextChatMessage(
            id: DateTime.now().toIso8601String(),
            text: textModelResponse.response,
            sender: MessageSender.assistant,
            timestamp: DateTime.now(),
          );

          final responseEvent =
              MessageResponseSent(originalMessage: message, message: response);

          GlobalEventBus.instance.fire(responseEvent);
        } else if (modelResponse.type == LLMResponseType.functionCall) {
          final FunctionCallLLMResponse fnCallResponse =
              modelResponse as FunctionCallLLMResponse;
          final responseEvent = InvokeFunctionResponseSent(
              functionCallRequest: fnCallResponse.response);
          GlobalEventBus.instance.fire(responseEvent);
        } else {
          throw ApplicationError(
              message:
                  'Unable to handle response from model. Unknown response type: ${modelResponse.type}');
        }
      } catch (error, stackTrace) {
        if (error is LlmModelError) {
          logger.error('LLM Model Error: ${error.message}');
          logger.error('Model: ${error.model.name} (${error.model.id})');
          logger.error('StackTrace: ${stackTrace}');
          if (error.cause != null) {
            logger.error('Caused by: ${error.cause}');
            // Try to log stack trace from cause, if available
            if (error.cause is Error) {
              logger.error('StackTrace: ${(error.cause as Error).stackTrace}');
            }
          }
        } else {
          logger.error('Unexpected error: $error');
          logger.error('StackTrace: $stackTrace');
        }
        final response = TextChatMessage(
          id: DateTime.now().toIso8601String(),
          text: '⚠️ The model is not available. Please try again later.',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
        );
        final responseEvent =
            MessageResponseSent(originalMessage: message, message: response);
        GlobalEventBus.instance.fire(responseEvent);
      }
    });

    _subscribedToEvents = true;
  }


  @override
  Future<LLMResponse> sendPrompt(
      {required LLMPromptBase prompt,
      TextLLMPrompt? behaviourPromptMessage,
      required List<LLMPromptBase> previousMessages,
      List<Map<String, dynamic>>? functions,
      dynamic functionCall}) async {
    logger.debug("LLM: sending prompt: ${prompt}");

    return selectedModel.sendPrompt(
        prompt: prompt,
        behaviourPromptMessage: behaviourPromptMessage,
        previousMessages: previousMessages,
        functions: functions,
        functionCall: functionCall);
  }

  Future<String> _getLocationInfo() async {
    logger.debug('Trying to fetch location info...');
    try {
      final response = await http.get(Uri.parse(_ipapiUri));
      if (response.statusCode == 200) {
        logger.debug('location info fetched successfully');
        return response.body;
      } else {
        logger
            .warn('Location fetch failed with status: ${response.statusCode}');
        return "Location info unavailable";
      }
    } catch (error) {
      logger.warn('Unable to fetch location info: $error');
      return "Location info unavailable";
    }
  }
}
