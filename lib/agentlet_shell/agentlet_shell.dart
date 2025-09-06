import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:wshell/agentlet_shell/manifest/manifest_exports.dart';
import 'package:wshell/shared/logger.dart';
import 'package:web/web.dart' as html;

abstract class IAgentShell {
  void sendMessageToShell(String message);
  void registerAgentlet(JSObject agentManifest);
}

const AGENT_SHELL_JS_OBJECT = 'agentlet_shell';

@JSExport()
class AgentletShell implements IAgentShell {
  final logger = WebLogger.createLogger(name: 'AgentletShell');
  static final AgentletShell _instance = AgentletShell._internal();

  factory AgentletShell() {
    return _instance;
  }

  AgentletShell._internal() {
    final jsObj = createJSInteropWrapper(this);
    html.window.setProperty(AGENT_SHELL_JS_OBJECT.toJS, jsObj);
  }

  void Function(String)? _sendMessageCallback;
  void Function(IManifestMini)? _registerAgentCallback;

  set onMessageSent(void Function(String)? callback) {
    _sendMessageCallback = callback;
  }

  set onAgentletRegistered(void Function(IManifestMini)? callback) {
    _registerAgentCallback = callback;
  }
 
  @override
  @JSExport('sendMessageToShell')
  void sendMessageToShell(String message) {
    logger.debug(' message received from javascript: $message');
    _sendMessageCallback?.call(message);
  }

  @override
  @JSExport('registerAgentlet')
  void registerAgentlet(JSObject agentManifestMini) {
    final manifest = ManifestParser.parse(agentManifestMini).v1_1_mini!;
    logger.debug('Agentlet registered with manifest = $manifest');
    _registerAgentCallback?.call(manifest);
  }
}
