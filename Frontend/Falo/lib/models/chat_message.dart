import 'package:uuid/uuid.dart';

enum MessageType {
  user,
  bot,
  loading,
  error
}

class ChatMessage {
  final String id;
  final MessageType type;
  final String? text;
  final Map<String, dynamic>? botResponseData;
  final String? sessionId;
  final DateTime? timestamp;

  const ChatMessage({
    required this.id,
    required this.type,
    this.text,
    this.botResponseData,
    this.sessionId,
    this.timestamp,
  });

  factory ChatMessage.loading() {
    return ChatMessage(
      id: const Uuid().v4(),
      type: MessageType.loading,
      text: null,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageType messageType;
    switch (json['type']) {
      case 'user':
        messageType = MessageType.user;
        break;
      case 'bot':
        messageType = MessageType.bot;
        break;
      case 'error':
        messageType = MessageType.error;
        break;
      case 'loading':
        messageType = MessageType.loading;
        break;
      default:
        messageType = MessageType.bot;
    }

    DateTime? timestamp;
    if (json['timestamp'] != null) {
      try {
        timestamp = DateTime.parse(json['timestamp']);
      } catch (e) {
        timestamp = null;
      }
    }

    return ChatMessage(
      id: json['id'] ?? const Uuid().v4(),
      type: messageType,
      text: json['text'],
      botResponseData: json['botResponseData'],
      sessionId: json['sessionId'],
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case MessageType.user:
        typeString = 'user';
        break;
      case MessageType.bot:
        typeString = 'bot';
        break;
      case MessageType.loading:
        typeString = 'loading';
        break;
      case MessageType.error:
        typeString = 'error';
        break;
    }

    return {
      'id': id,
      'type': typeString,
      'text': text,
      'botResponseData': botResponseData,
      'sessionId': sessionId,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}