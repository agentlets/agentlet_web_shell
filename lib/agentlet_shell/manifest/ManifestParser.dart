
import 'dart:convert';
import 'dart:js_interop';

import 'package:wshell/agentlet_shell/manifest/manifest_interfaces.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_v1.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_v1_1.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_v1_1_mini.dart';
import 'package:wshell/shared/js_helper.dart';


main() {
    final JSObject jsManifest = jsObjectFromJsonString(_manifestText);
    //final String manifestString = jsonStringFromJSObject(jsManifest);
    //final dynamic dartManifest = jsonDecode(manifestString);
    final manifest = ManifestParser.parse(jsManifest);
    print('AgentletShell: Agentlet registered with manifest = $manifest');
}

String _manifestText = '''
{
  "manifestVersion": "1.1.0",
  "name": "Tic Tac Toe",
  "version": "0.1.1",
  "tagName": "tic-tac-toe",
  "description": "Juego de Tateti (3 en línea) jugado por turnos entre un humano y una IA.",
  "behavior_prompt": [
    "Eres un agente que juega tic-tac-toe con el usuario.",
    "Tu rol como siempre eres asistente.",
    "La matriz de juego comienza en (0,0) y termina en (2,2).",
    "Las coordenadas se indican asi: (row, col)",
    "El usuario juega con la 'X' y tú (el asistente) con la 'O'.",
    "Cuando el usuario juega, es decir, termina su turno, entonces comienza tu turno de jugar. Para tu jugar debes llamar a la función agentlet_placeMove indicando la jugada que harás como asistente.",
    "Si la función agentlet_placeMove devuelve status = OK, invita al usuario a jugar el siguiente turno y espera.",
    "Si la funcion agentlet_placeMove devuelve status = ERROR, detente e indica al usuario que te equivocaste y que te confirme si desea que tu (asistente) pueda volver a intentar.",
    "Todas las funciones con prefijo 'agentlet_' devuelven status, messsage (un mensaje descriptivo) y response con la matriz actualizada del juego.",
    "la matriz actualizada del juego para que sepas donde puedes jugar y donde no.",
    "No respondas con texto directamente. No expliques tus movimientos. Solo responde con la función correspondiente.",
    "Si detectas que ganaste, puedes incluir un mensaje en texto para avisarlo y preguntar si quiere jugar de nuevo."
  ],
  "tools": [
    {
      "name": "agentlet_placeMove",
      "description": "Usa esta función para indicar en qué celda el asistente quiere jugar en Tic-Tac-Toe (jugador 'O').",
      "parameters": {
        "type": "object",
        "properties": {
          "row": {
            "type": "integer",
            "description": "Índice de la fila donde el asistente quiere jugar (0-2)."
          },
          "col": {
            "type": "integer",
            "description": "Índice de la columna donde el asistente quiere jugar (0-2)."
          }
        },
        "required": ["row", "col"]
      }
    },
    {
      "name": "agentlet_clearBoard",
      "description": "Usa esta función para reiniciar el tablero de Tic-Tac-Toe. Limpia todas las celdas y comienza un nuevo juego.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  ]
}           
''';

abstract class ManifestParser {
  static IManifestMini parse(JSObject jsManifest) {
   
    final String manifestString = jsonStringFromJSObject(jsManifest);
    final dynamic manifestMap = jsonDecode(manifestString);

    final manifestVersion = manifestMap['manifestVersion'] ?? '1.0.0';

    switch (manifestVersion) {
      case '1.0.0':
        return ManifestV1.fromJs(manifestMap);
      case '1.1.0':
        return ManifestV1_1.fromJs(manifestMap);
      case '1.1.0-mini':
        return ManifestV1_1_Mini.fromJs(manifestMap);
      default:
        throw UnsupportedError(
            'Manifest version $manifestVersion is not supported.');
    }
  }
}
