// models/chatsession.dart
class ChatSession {
  final String sessionId;
  final String name;
  final DateTime createdAt;
  final DateTime lastActivity;

  ChatSession({
    required this.sessionId,
    required this.name,
    required this.createdAt,
    required this.lastActivity,
  });

  // Add this copyWith method
  ChatSession copyWith({
    String? sessionId,
    String? name,
    DateTime? createdAt,
    DateTime? lastActivity,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'] ?? '',
      name: json['name'] ?? 'New Chat',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'lastActivity': lastActivity.toIso8601String(),
  };
}