// ignore_for_file: avoid_print
class WebLogger {
  final String name;

  WebLogger._(this.name);

  factory WebLogger.createLogger({required String name}) {
    return WebLogger._(name);
  }

  Future<void> info(String message) async {
    final taggedMessage = '[$name] $message';
    print('INFO: $taggedMessage');
  }

  Future<void> warn(String message) async {
    final taggedMessage = '[$name] $message';
    print('WARN: $taggedMessage');
    ;
  }

  Future<void> error(String message) async {
    final taggedMessage = '[$name] $message';
    print('ERROR: $taggedMessage');
  }

  Future<void> debug(String message) async {
    final taggedMessage = '[$name] $message';
    print('DEBUG: $taggedMessage');
  }

  Future<void> log(String message) async {
    final taggedMessage = '[$name] $message';
    print('LOG: $taggedMessage');
  }
}
