import 'dart:js_interop';

import 'package:wshell/shared/js_helper.dart';
import 'package:wshell/shared/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui_web';
import 'package:wshell/agentlet_shell/manifest/manifest_exports.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:web/web.dart' as html;
import 'package:flutter/material.dart';
import 'package:wshell/shared/event_bus.dart';

class AgentletLoaderController {
  static final logger =
      WebLogger.createLogger(name: 'AgentletLoaderController');
  _AgentletLoaderState? _state;
  String _agentletBaseURL = '';
  IManifest? _agentletManifest;

  set agentletBaseURL(String url) {
    logger.debug('agentletBaseURL changed to: $url');
    _agentletBaseURL = url;
  } 

  String get agentletBaseURL => _agentletBaseURL;

  String get agentletWebComponentURL => '$_agentletBaseURL/agentlet.js';

  String get agentletManifestURL => '$_agentletBaseURL/agentlet_manifest.json';

  IManifest? get agentletManifest => _agentletManifest;

  void _bind(_AgentletLoaderState state) {
    _state = state;
  }

  Future<IManifest> loadManifest() async {
    final url = agentletManifestURL;
    logger.debug('Loading manifest from $url...');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final manifestText = response.body;
        final JSObject jsManifest = jsObjectFromJsonString(manifestText);
        _agentletManifest = ManifestParser.parse(jsManifest).v1_1;
        return _agentletManifest!;
      } else {
        throw Exception(
            'Error al cargar el manifiesto: ${response.statusCode}');
      }
    } catch (e) {
      logger.error('Error al cargar el manifiesto: $e');
      rethrow;
    }
  }

  void sendMessageToFlutter(String message) {
    logger.debug('Rae message to handle: $message');
    final jsonMessage = jsonDecode(message);
    final messageType = jsonMessage['type'];

    if (messageType == 'message') {
      final messageText = jsonMessage['message'];
      _state?.sendMessageToFlutter(messageText);
      _sendMessageToModel(messageText);
    }
    if (messageType == 'tool_response') {
      _sendToolResponseToModel(jsonMessage);
    }
  }

  void sendMessageToWebComponent(String message) {
    _state?.sendMessageToWebComponent(message);
  }

  void renderWebComponent() {
    if (_agentletManifest == null) {
      logger.warn("Unable to render Agentlet: no manifest");
      return;
    }
    logger.debug('try to render WebComponent');
    _state?.renderWebComponent(_agentletManifest!);
  }

  void _sendMessageToModel(String text) {
    final event = AgentletMessageSent(
      message: text,
    );
    GlobalEventBus.instance.fire(event);
  }

  void _sendToolResponseToModel(dynamic response) {
    logger.debug('sending FunctionCallResponseSent event from: ${response}...');

    final Map<String, dynamic> params = response['params'];
    final event = FunctionCallResponseSent(
        functionCallRequest: FunctionCallRequest(
            callId: params['__call_id'],
            functionName: response['tool'], 
            arguments: params),
        response: response['response']);
    GlobalEventBus.instance.fire(event);
    logger.debug('event sent: $event');
  }
}

class AgentletLoader extends StatefulWidget {
  final AgentletLoaderController controller;

  AgentletLoader({super.key, required this.controller});

  @override
  State<AgentletLoader> createState() => _AgentletLoaderState();
}

class _AgentletLoaderState extends State<AgentletLoader> {
  static final logger = WebLogger.createLogger(name: 'AgentletLoader');
  String? _viewType;
  // ignore: unused_field
  String _lastMessageReceived = '';

  html.Element? _webComponent;

  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadWebComponent()
        .then((_) {
            renderWebComponent(widget.controller.agentletManifest!);
        });
    });
  }

  void sendMessageToFlutter(String message) {
    logger.debug('Message to Send to flutter: $message');
    setState(() {
      _lastMessageReceived = message;
    });
  }

  Future<void> loadWebComponent() async {
    logger.debug('loading agentlet web component...');
    final scriptUrl = widget.controller.agentletWebComponentURL;

    logger.debug('agentlet script source: $scriptUrl');

    // construye el ID del script
    final scriptId = widget.controller.agentletManifest!.componentId;
     logger.debug('Agentlet script ID is $scriptId');

    // valida si existe el script
    final existentScript = html.document.getElementById(scriptId);

    if (existentScript != null) {
      logger.warn('Script already injected. Removing previous script...');
      html.document.body!.removeChild(existentScript);
    }

    // Inyectar el script en tiempo de ejecución
    logger.debug('creating agentlet script...');
    final script =
        (html.document.createElement('script') as html.HTMLScriptElement)
          ..id = scriptId
          ..src = scriptUrl
          ..type = 'module';

    logger.debug('injecting agentlet script in main window...');
    html.document.body!.appendChild(script);
    logger.debug('agentlet script injection successfully.');
  }

  Future<void> renderWebComponent(IManifest manifest) async {
    logger.debug('rendering agentlet...');

    final tagName = manifest.componentId;
    logger.debug('tagName to register in shell: <$tagName>');

    setState(() {
      // Registrar la vista
      logger.debug('creating new HTML element...');
      final element = html.document.createElement(tagName);
      _webComponent = element;

      _viewType = '$tagName-${DateTime.now().millisecondsSinceEpoch}';
      logger.debug('viewType to register in shell: ${_viewType}');

      // Registrar en Flutter
      logger.debug('registering and mapping viewType to HTML element...');
      platformViewRegistry.registerViewFactory(
          _viewType!, (int viewId) => element);
    });
    logger.debug('agentlet render successfully');
  }

  void sendMessageToWebComponent(String message) {
    if (_webComponent != null) {
      _webComponent!.setAttribute('message', message);
      logger.debug('message sent to Agentlet: $message...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: _buildWebContainer(),
        ));
  }

  Widget _buildWebContainer() {
    if (_viewType != null) {
      logger.debug('building web container using viewType: ${_viewType}...');
      return HtmlElementView(viewType: _viewType!);
    } else {
      logger.warn('building progress indicator because _viewType is NULL.');
      return _buildProgressIndicator();
    }
  }

  Widget _buildProgressIndicator() {
    if (widget.controller._agentletManifest is! ManifestV1_1) {
      return CircularProgressIndicator();
    }

    final manifestV1_1 = widget.controller._agentletManifest as ManifestV1_1;
    final imageURL = manifestV1_1.iconURL;

    if (imageURL.isEmpty) {
      return CircularProgressIndicator();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Image.network(imageURL, width: 40, height: 40),
      ],
    );
  }
}
