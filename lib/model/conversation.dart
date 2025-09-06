
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/app_error.dart';
import 'package:uuid/uuid.dart';

class Conversation {
  final String id;
  String name;
  String headline;
  DateTime lastUpdated;
  List<String> hashtags;
  List<ChatMessageBase> _messages;

  static Conversation get empty => Conversation(id: '', name: '');

  Conversation(
      {String? id,
      this.name = 'new Conversation',
      this.headline = '',
      DateTime? lastUpdated,
      List<String>? hashtags,
      List<ChatMessageBase>? messages})
      : id = id ?? Uuid().v4(),
        lastUpdated = lastUpdated ?? DateTime.now(),
        hashtags = hashtags ?? [],
        _messages = messages ?? [];

  Conversation clone() {
    return Conversation(
      id: id,
      name: name,
      headline: headline,
      lastUpdated: lastUpdated,
      hashtags: List.from(hashtags),
      messages: List.from(_messages),
    );
  }

  List<ChatMessageBase> get messages => List.from(_messages, growable: false);

  void appendMessage(ChatMessageBase newMessage) {
    final newMaxSequence = _getMaxSequence() + 1;
    newMessage.sequence = newMaxSequence;
    _messages.insert(0, newMessage);
  }

  int _getMaxSequence() {
    if (_messages.isEmpty) return 0;
    return _messages.map((m) => m.sequence).reduce((a, b) => a > b ? a : b);
  }

  void updateFrom(Conversation other) {
    name = other.name;
    headline = other.headline;
    lastUpdated = other.lastUpdated;
    hashtags = List.from(other.hashtags);
    _messages = List.from(other._messages);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Conversation &&
        other.id == id &&
        other.name == name &&
        other.headline == headline &&
        other.lastUpdated == lastUpdated &&
        _listEquals(other.hashtags, hashtags) &&
        _listEquals(other._messages, _messages);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      headline.hashCode ^
      lastUpdated.hashCode ^
      hashtags.hashCode ^
      _messages.hashCode;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, name: $name, headline: $headline, lastUpdated: $lastUpdated, hashtags: $hashtags, messages count: ${_messages.length})';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'headline': headline,
      'lastUpdated': lastUpdated.toIso8601String(),
      'hashtags': hashtags,
      'messages': _messages.map((m) => m.toMap()).toList(),
    };
  }

  static Conversation fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      name: map['name'] ?? '',
      headline: map['headline'] ?? '',
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      hashtags: List<String>.from(map['hashtags'] ?? []),
      messages: (map['messages'] as List<dynamic>?)?.map((msg) {
            switch (msg['type']) {
              case 'text':
                return ChatMessageBase.fromMap(Map<String, dynamic>.from(msg))
                    as TextChatMessage;
              case 'function':
                return ChatMessageBase.fromMap(Map<String, dynamic>.from(msg))
                    as FunctionCallResponseMessage;
              default:
                throw ApplicationError(
                    message: 'Unsupported type in fromMap: ${msg['type']}');
            }
          }).toList() ??
          [],
    );
  }
}
