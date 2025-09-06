// home.dart
import 'package:flutter/material.dart';
import 'package:wshell/agentlet_shell/agentlet_shell.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_interfaces.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_v1_1.dart';
import 'package:wshell/model/agentlet_item.dart';
import 'package:wshell/shared/chat_controller.dart';
import 'package:wshell/shared/event_bus.dart';
import 'package:wshell/shared/logger.dart';
import 'package:wshell/shared/web_utils.dart';
import 'package:wshell/widgets/agentlet_loader.dart';
import 'package:wshell/widgets/chat/chat_area.dart';

class HomePage extends StatefulWidget {
  

  const HomePage({super.key});
     
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Agentlet? _currentAgentlet;
  late ChatController chatController;
  late final AgentletShell agentletShell;
  late final AgentletLoader webComponentLoader;
  late final AgentletLoaderController agentletLoaderController;
  String agentletChatName = '';
  final logger = WebLogger.createLogger(name: 'HomePage');

  @override
  void initState() {
    super.initState();

    _currentAgentlet = BuiltinAgentlet(
      id: 'io-ggobuk-builtin-tic-tac-toe-0-1-1',
      name: 'Tic Tac Toe',
      iconUrl: '/builtin/tic-tac-toe/icon.png',
      agentletBaseUrl: '${appURL}builtin/tic-tac-toe',
      licenseType: LicenseType.openSource,
    );

    GlobalEventBus.instance.fire(ApplicationTitleUpdated(appTitle: _currentAgentlet!.name));

    agentletShell = AgentletShell();
    agentletLoaderController = AgentletLoaderController();

    webComponentLoader = AgentletLoader(
      controller: agentletLoaderController,
    );

    agentletShell.onAgentletRegistered = ((manifest) {
      if (manifest != agentletLoaderController.agentletManifest) {
        logger.error('Loaded manifest and registered manifes missmatch');
      }
      setState(() {});
      agentletLoaderController.renderWebComponent();
    });

    agentletShell.onMessageSent =
        (message) => agentletLoaderController.sendMessageToFlutter(message);

    chatController = ChatController();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _subscribeToEvents() async {}

  String get _agentletBehaviourPrompt =>
      agentletLoaderController.agentletManifest?.v1_1?.behaviorPrompt ?? '';

  List<Map<String, dynamic>> _getAgentletFunctions() {
    final List<Map<String, dynamic>> result = agentletLoaderController
            .agentletManifest?.v1_1?.tools
            .map((tool) => tool.toMap())
            .toList() ??
        [];

    logger.debug(
        'Agentlet raw functions: ${agentletLoaderController.agentletManifest?.v1_1?.tools ?? 'no-tools'}}');
    logger.debug('Agentlet mapped functions: $result');
    return result;
  }

  Widget _buildAgentletWebComponent() {
    return webComponentLoader;
  }

  Widget _buildChatWorkspace() {
    if (_currentAgentlet == null) {
      return Center(child: Text("No Agentlet was selected"));
    }

    logger.debug("SHOW Agentlet: ${_currentAgentlet.toString()}");

    agentletLoaderController.agentletBaseURL =
        _currentAgentlet!.agentletBaseUrl!;

    logger.debug(
        "Agentlet base URL: ${agentletLoaderController.agentletBaseURL}");

    return FutureBuilder<IManifest>(
      future: agentletLoaderController.loadManifest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          logger.error('Unable to load Agentlet: ${snapshot.error}');
          return Center(child: Text('Error loading Agentlet'));
        }

        final ManifestV1_1 manifest = snapshot.data! as ManifestV1_1;
        logger.debug(
            'Agentlet manifest loaded: ${manifest.name} - ${manifest.version}');

        chatController = ChatController();
        chatController.setBehaviour(_agentletBehaviourPrompt);
        chatController.functions = _getAgentletFunctions();
        GlobalEventBus.instance.fire(ChatCleared());
        //GlobalEventBus.instance.fire(ApplicationTitleUpdated(appTitle: manifest.name));
       
        return SizedBox.expand(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.grey[850],
                  child: Center(
                    child: _buildAgentletWebComponent(),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: ChatArea(chatController: chatController),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _buildChatWorkspace(),
    );
  }
}
