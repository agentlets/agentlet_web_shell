import 'dart:async';
import 'dart:html' as html;
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/app_error.dart';
import 'package:wshell/shared/event_bus.dart';
import 'package:wshell/shared/llm/llm_model.dart';
import 'package:wshell/shared/llm/no_model.dart';
import 'package:wshell/shared/logger.dart';



class LlmModels implements LlmModel {
  static final _ipapiUri = Uri.parse('https://ipapi.co/json/');
  static final logger = WebLogger.createLogger(name: 'LlmModels');
  String _locationInfo = "Location info unavailable";
  bool _subscribedToEvents = false;

  LlmModels._privateConstructor() {
    _getLocationInfo().then((locationInfo) {
      _locationInfo = locationInfo;
    });
  }
  static final LlmModels _instance = LlmModels._privateConstructor();

  factory LlmModels() {
    return _instance;
  }

  LlmModel _selectedModel = NoModel();

  LlmModel get selectedModel => _selectedModel;

  Completer<LlmModel> _completableForGetCurrentSelectedModel =
      Completer<LlmModel>();

  set selectedModel(LlmModel model) {
    _selectedModel = model;
    if (!_completableForGetCurrentSelectedModel.isCompleted) {
      _completableForGetCurrentSelectedModel.complete(_selectedModel);
    } else {
      _completableForGetCurrentSelectedModel = Completer<LlmModel>();
      _completableForGetCurrentSelectedModel.complete(_selectedModel);
    }
  }

  Future<LlmModel> getCurrentSelectedModel() =>
      _completableForGetCurrentSelectedModel.future;

  @override
  String get id => selectedModel.id;

  @override
  String get name => selectedModel.name;

  @override
  String get provider => selectedModel.provider;

  @override
  Future<LLMResponse> sendPrompt(
      {required LLMPromptBase prompt,
      TextLLMPrompt? behaviourPromptMessage,
      required List<LLMPromptBase> previousMessages,
      List<Map<String, dynamic>>? functions,
      dynamic functionCall}) async {
    logger.debug("LLM: sending prompt: ${prompt}");

    if (selectedModel is NoModel) {
      await this.loadModelConfig();
    }

    return selectedModel.sendPrompt(
        prompt: prompt,
        behaviourPromptMessage: behaviourPromptMessage,
        previousMessages: previousMessages,
        functions: functions,
        functionCall: functionCall);
  }

  Future<String> _getLocationInfo() async {
    logger.debug('Trying to fetch location info...');
    final httpClient = ElectronHttpClient();
    try {
      final response = await httpClient.get(_ipapiUri);
      logger.debug('location info fetch successfully');
      return response.body;
    } catch (error) {
      logger.warn('Unable to fetch location info: $error');
      return "Location info unavailable";
    }
  }
}
