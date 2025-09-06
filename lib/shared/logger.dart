import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class WebLogger {
  final String name;

  WebLogger._(this.name);

  factory WebLogger.createLogger({required String name}) {
    return WebLogger._(name);
  }

  JSObject get _console =>
      (globalContext.getProperty('console'.toJS) as JSObject);

  Future<void> info(String message) async {
    final taggedMessage = '[$name] $message';
    _console.callMethod<JSAny>('info'.toJS, [taggedMessage.toJS].toJS);
  }

  Future<void> warn(String message) async {
    final taggedMessage = '[$name] $message';
    _console.callMethod<JSAny>('warn'.toJS, [taggedMessage.toJS].toJS);
  }

  Future<void> error(String message) async {
    final taggedMessage = '[$name] $message';
    _console.callMethod<JSAny>('error'.toJS, [taggedMessage.toJS].toJS);
  }

  Future<void> debug(String message) async {
    final taggedMessage = '[$name] $message';
    _console.callMethod<JSAny>('debug'.toJS, [taggedMessage.toJS].toJS);
  }

  Future<void> log(String message) async {
    final taggedMessage = '[$name] $message';
    _console.callMethod<JSAny>('log'.toJS, [taggedMessage.toJS].toJS);
  }
}
