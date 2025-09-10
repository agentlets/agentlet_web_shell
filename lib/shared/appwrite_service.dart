import 'package:appwrite/appwrite.dart';
import 'environment.dart';

/// AppwriteService implemented as a lazy singleton.
///
/// Usage:
/// - Initialize once: `await AppwriteService.instance.init(endpoint: ..., projectId: ..., selfSigned: true);`
/// - Then access clients: `AppwriteService.instance.databases` etc.
class AppwriteService {
  // Private constructor
  AppwriteService._internal();

  // The single shared instance
  static final AppwriteService instance = AppwriteService._internal();

  Client? _client;
  Account? _account;
  Databases? _databases;
  Storage? _storage;
  Functions? _functions;

  /// Initialize the Appwrite client and SDK services.
  /// It is safe to call multiple times; subsequent calls reuse the same client
  /// unless you pass `force: true` to recreate it.
  Future<void> init({
    String? endpoint,
    String? projectId,
    bool selfSigned = false,
    bool force = false,
  }) async {
    if (_client != null && !force) return;

    final ep = endpoint ?? Environment.appwritePublicEndpoint;
    final pid = projectId ?? Environment.appwriteProjectId;

    final client = Client()
        .setEndpoint(ep)
        .setProject(pid)
        .setSelfSigned(status: selfSigned);

    _client = client;
    _account = Account(client);
    _databases = Databases(client);
    _storage = Storage(client);
    _functions = Functions(client);
  }

  /// Whether the service has been initialized.
  bool get isReady => _client != null;

  /// Low-level client. Throws if not initialized.
  Client get client => _require(_client, 'Client');

  /// Account API accessor.
  Account get account => _require(_account, 'Account');

  /// Databases API accessor.
  Databases get databases => _require(_databases, 'Databases');

  /// Storage API accessor.
  Storage get storage => _require(_storage, 'Storage');

  /// Functions API accessor.
  Functions get functions => _require(_functions, 'Functions');

  T _require<T>(T? value, String name) {
    if (value == null) {
      throw StateError('AppwriteService not initialized: $name unavailable');
    }
    return value;
  }

  /// Ensures there is a current session (anonymous if needed) and returns its JWT.
  /// If no session exists, creates an anonymous session, then issues a JWT.
  Future<String> getJwtFromAnonymousLogin() async {
    // Ensure client/account are available
    final acc = account;

    // Try to get current sessions; if none, create anonymous session
    try {
      final sessions = await acc.listSessions();
      final hasCurrent = sessions.sessions.any((s) => s.current == true);
      if (!hasCurrent) {
        await acc.createAnonymousSession();
      }
    } catch (_) {
      // If listing sessions fails (e.g., no session), attempt anonymous login
      await acc.createAnonymousSession();
    }

    // Now create a JWT for the current session
    final jwt = await acc.createJWT();
    return jwt.jwt;
  }
}
