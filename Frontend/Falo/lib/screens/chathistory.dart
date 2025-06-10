
import 'chatsession.dart';

abstract class ChatHistoryService {
  Future<List<ChatSession>> getChatSessions();
  Future<ChatSession?> getChatSession(String id);
  Future<void> saveChatSession(ChatSession session);
  Future<void> deleteChatSession(String id);
}