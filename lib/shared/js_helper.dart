import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:wshell/shared/logger.dart';



dynamic getJSObjectProperty(JSObject jsObject, String key) {
  final logger = WebLogger.createLogger(name: 'JS.getJSObjectProperty');
  try {
    return jsObject.getProperty(key.toJS);
  } catch (e) {
    logger.warn('Unable to get property from JSObject: $e');
    return null;
  }
}

List<String> getJSObjectKeys(JSObject jsObject) {
  final logger = WebLogger.createLogger(name: 'JS.getJSObjectKeys');
  try {
    final jsObject = globalContext.getProperty('Object'.toJS) as JSObject;
    final jsKeys = jsObject.callMethod<JSArray>('keys'.toJS, jsObject);
   
    // Llama a Object.keys(jsObject)
    // final jsKeys = globalContext.callMethod<JSArray>('Object.keys'.toJS, [jsObject].toJS);

    final length = jsKeys.length;
    final keys = <String>[];

    for (var i = 0; i < length; i++) {
      // ignore: sdk_version_since
      final key = jsKeys[i];
      keys.add(key.toString());
    }

    return keys;
  } catch (e) {
    logger.warn('Unable to get keys from JSObject: $e');
    return [];
  }
}

JSObject jsObjectFromDart(dynamic dartValue) {
  final logger = WebLogger.createLogger(name: 'JS.jsObjectFromDart');
  if (dartValue is Map<String, dynamic>) {
    final jsObj = JSObject();
    for (var entry in dartValue.entries) {
      jsObj.setProperty(entry.key.toJS, jsObjectFromDart(entry.value));
    }
    return jsObj;
  } else if (dartValue is List) {
    final jsArray = <JSAny>[].toJS;
    for (var item in dartValue) {
      jsArray.add(jsObjectFromDart(item));
    }
    return jsArray as JSObject;
  } else if (dartValue is String) {
    return dartValue.toJS as JSObject;
  } else if (dartValue is num) {
    return dartValue.toJS as JSObject;
  } else if (dartValue is bool) {
    return dartValue.toJS as JSObject;
  } else if (dartValue == null) {
    return JSObject(); // Return empty object for null
  } else {
    logger.error('Unsupported Dart type for JS conversion: ${dartValue.runtimeType}');
    throw ArgumentError('Unsupported Dart type for JS conversion: ${dartValue.runtimeType}');
  }
}

JSObject jsObjectFromJsonString(String jsonString) {
  final logger = WebLogger.createLogger(name: 'JS.jsObjectFromJsonString');
  try {
    final jsJson = globalContext.getProperty('JSON'.toJS) as JSObject;
    final parsed = jsJson.callMethod<JSAny>('parse'.toJS, [jsonString.toJS].toJS);
    return parsed as JSObject;
  } catch (e) {
    logger.error('Invalid JSON string: $e');
    throw FormatException('Invalid JSON string: $e');
  }
}

String jsonStringFromJSObject(JSObject jsObject) {
  final logger = WebLogger.createLogger(name: 'JS.jsonStringFromJSObject');
  try {
    final jsJson = globalContext.getProperty('JSON'.toJS) as JSObject;
    final jsonString = jsJson.callMethod<JSString>('stringify'.toJS, jsObject);
    return jsonString.toDart;
  } catch (e) {
    logger.error('Unable to stringify JS object: $e');
    throw FormatException('Unable to stringify JS object: $e');
  }
}
