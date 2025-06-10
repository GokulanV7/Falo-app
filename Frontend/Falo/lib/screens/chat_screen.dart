import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:anewdehli12/models/chat_message.dart';
import 'FaloListeningDialog.dart';
import 'chatsession.dart';
import 'package:anewdehli12/services/misinformation_service.dart';
import 'package:anewdehli12/widgets/message_bubble.dart';
import 'package:anewdehli12/theme_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'appbar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MisinformationService _misinformationService = MisinformationService();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isLoadingSessions = false;
  bool _isSearching = false;
  List<ChatMessage> _searchResults = [];
  late AnimationController _sendButtonController;

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  String _translatedText = '';

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeChat();
  }
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        },
      );
    } else {
      print('Speech recognition unavailable');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _initializeChat() async {
    await _loadSessions();
    if (_sessions.isEmpty) {
      await _createNewSession();
    } else {
      // Load the most recent session
      _sessions.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      await _loadSession(_sessions.first.sessionId);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final response =
          await http.get(Uri.parse('http://110.172.151.110:5001/sessions'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _sessions = data.map((e) => ChatSession.fromJson(e)).toList();
          _sessions.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        });
      }
    } catch (e) {
      debugPrint('Failed to load sessions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sessions: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSessions = false);
      }
    }
  }

  Future<void> _createNewSession() async {
    final newSessionId = _uuid.v4();
    final newSession = ChatSession(
      sessionId: newSessionId,
      name: 'New Chat ${DateFormat('MMM d, h:mm a').format(DateTime.now())}',
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );

    setState(() {
      _currentSessionId = newSessionId;
      _messages = [];
      _isSearching = false;
      _searchResults = [];
    });

    await _saveSession(newSession);
    _addWelcomeMessage();
  }

  Future<void> _saveSession(ChatSession session) async {
    try {
      final response = await http.post(
        Uri.parse('http://110.172.151.110:5001/save-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(session.toJson()),
      );

      if (response.statusCode == 200) {
        await _loadSessions();
      } else {
        debugPrint('Failed to save session: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to save session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save session: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadSession(String sessionId) async {
    debugPrint('Loading session: $sessionId');

    setState(() {
      _isLoading = true;
      _currentSessionId = sessionId;
      _isSearching = false;
      _searchResults = [];
      _messages = [];
    });

    try {
      final response = await http.get(
          Uri.parse('http://http://110.172.151.110:5001/messages/$sessionId'));
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final loadedMessages =
            data.map((e) => ChatMessage.fromJson(e)).toList();

        setState(() {
          _messages = loadedMessages;
          if (_messages.isEmpty) {
            _addWelcomeMessage();
          }
        });

        // Update session name if it's generic
        final sessionIndex =
            _sessions.indexWhere((s) => s.sessionId == sessionId);
        if (sessionIndex != -1 &&
            _sessions[sessionIndex].name.startsWith('New Chat')) {
          final firstUserMessage = _messages.firstWhere(
            (m) => m.type == MessageType.user,
            orElse: () => ChatMessage(
              id: '',
              type: MessageType.bot,
              text: '',
              sessionId: sessionId,
            ),
          );

          if (firstUserMessage.text != null &&
              firstUserMessage.text!.isNotEmpty) {
            await _updateSessionName(
              sessionId,
              firstUserMessage.text!.length > 30
                  ? '${firstUserMessage.text!.substring(0, 30)}...'
                  : firstUserMessage.text!,
            );
          }
        }
      } else {
        debugPrint('Error loading messages: ${response.statusCode}');
        _addWelcomeMessage();
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: ${e.toString()}')),
        );
        _addWelcomeMessage();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearHistory() async {
    try {
      final response =
          await http.post(Uri.parse('http://110.172.151.110:5001/clear'));
      if (response.statusCode == 200) {
        setState(() {
          _sessions = [];
        });
        await _createNewSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear history: ${e.toString()}')),
        );
      }
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.bot,
      text: "Hello! I'm Falo, your misinformation detection assistant. "
          "Send me any text or URL to analyze its credibility.",
      sessionId: _currentSessionId,
    );
    _addMessageToList(welcomeMessage, delay: 1000);
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _sendButtonController
        .forward()
        .then((_) => _sendButtonController.reverse());
    _textController.clear();
    FocusScope.of(context).unfocus();

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      text: text,
      sessionId: _currentSessionId,
    );
    _addMessageToList(userMessage);
    await _saveMessage(userMessage);

    if (_messages.where((m) => m.type == MessageType.user).length == 1) {
      await _updateSessionName(
        _currentSessionId!,
        text.length > 30 ? '${text.substring(0, 30)}...' : text,
      );
    }

    final loadingMessage = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.loading,
      text: "",
      sessionId: _currentSessionId,
    );
    _addMessageToList(loadingMessage);

    setState(() => _isLoading = true);
    _scrollToBottom(delayMilliseconds: 100);

    try {
      final botResponseData = await _misinformationService
          .analyzeText(text)
          .timeout(const Duration(seconds: 30));

      _removeLoadingMessage();

      final botMessage = ChatMessage(
        id: _uuid.v4(),
        type: MessageType.bot,
        text: botResponseData['text'] ?? "I've analyzed your input.",
        botResponseData: botResponseData,
        sessionId: _currentSessionId,
      );
      _addMessageToList(botMessage);
      await _saveMessage(botMessage);
    } catch (e) {
      _removeLoadingMessage();
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _scrollToBottom(delayMilliseconds: 300);
    }
  }

  Future<void> _updateSessionName(String sessionId, String newName) async {
    try {
      final sessionIndex =
          _sessions.indexWhere((s) => s.sessionId == sessionId);
      if (sessionIndex != -1) {
        final updatedSession = _sessions[sessionIndex].copyWith(
          name: newName,
          lastActivity: DateTime.now(),
        );

        setState(() {
          _sessions[sessionIndex] = updatedSession;
        });

        await _saveSession(updatedSession);
      }
    } catch (e) {
      debugPrint('Error updating session name: $e');
    }
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      // Update session last activity
      final sessionIndex =
          _sessions.indexWhere((s) => s.sessionId == _currentSessionId);
      if (sessionIndex != -1) {
        final updatedSession = _sessions[sessionIndex].copyWith(
          lastActivity: DateTime.now(),
        );
        setState(() {
          _sessions[sessionIndex] = updatedSession;
        });
        await _saveSession(updatedSession);
      }

      debugPrint('Saving message: ${jsonEncode(message.toJson())}');
      final response = await http.post(
        Uri.parse('http://110.172.151.110:5001/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to save message: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to save message: $e');
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults.clear();
      }
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchResults = _messages
          .where((msg) =>
              (msg.text ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildChatHistoryList() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayChats =
        _sessions.where((s) => s.lastActivity.isAfter(today)).toList();
    final yesterdayChats = _sessions
        .where((s) =>
            s.lastActivity.isAfter(yesterday) && !s.lastActivity.isAfter(today))
        .toList();
    final olderChats =
        _sessions.where((s) => !s.lastActivity.isAfter(yesterday)).toList();

    return Column(
      children: [
        if (todayChats.isNotEmpty) _buildSection('Today', todayChats),
        if (yesterdayChats.isNotEmpty)
          _buildSection('Yesterday', yesterdayChats),
        if (olderChats.isNotEmpty) _buildSection('Older', olderChats),
        if (_sessions.isEmpty) _buildEmptyState(),
      ],
    );
  }

  Widget _buildSection(String title, List<ChatSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        ...sessions.map((session) => _buildChatItem(session)).toList(),
      ],
    );
  }

  Widget _buildChatItem(ChatSession session) {
    final theme = Theme.of(context);
    final isSelected = session.sessionId == _currentSessionId;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chat_bubble_outline,
          size: 20,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        session.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        DateFormat('MMM d, h:mm a').format(session.lastActivity),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: () async {
        Navigator.pop(context);
        await _loadSession(session.sessionId);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No chat history yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentBrightness = Theme.of(context).brightness;

    // Determine the current chat session name
    String currentSessionName = 'Falo';
    if (_currentSessionId != null) {
      final currentSession = _sessions.firstWhere(
        (s) => s.sessionId == _currentSessionId,
        orElse: () => ChatSession(
          sessionId: '',
          name: 'Falo',
          createdAt: DateTime.now(),
          lastActivity: DateTime.now(),
        ),
      );
      currentSessionName = currentSession.name;
    }

    return Scaffold(
      drawer: Drawer(
        width: 280,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Lottie.asset(
                'images/robo.json',
                width: 100,
                height: 100,
                repeat: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Chat'),
                  onPressed: () {
                    Navigator.pop(context);
                    _createNewSession();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoadingSessions
                  ? const Center(child: CircularProgressIndicator())
                  : _buildChatHistoryList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Clear All Chats'),
                  onPressed: () {
                    Navigator.pop(context);
                    _clearHistory();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.error,
                    ),
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: ProfessionalAppBar(),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _isSearching
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (ctx, i) => MessageBubble(
                        message: _searchResults[i],
                        animation: const AlwaysStoppedAnimation(1.0),
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'images/robo.json',
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Start a conversation with Falo",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Ask me to analyze any text or URL for misinformation",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (ctx, i) {
                            return MessageBubble(
                              message: _messages[i],
                              animation: const AlwaysStoppedAnimation(1.0),
                            );
                          },
                        ),
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center-align vertically
        children: [
          // 📝 Text Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter text or URL...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 14.0,
                  ),
                  suffixIcon: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Lottie.asset(
                            'images/robo.json',
                            width: 30,
                            height: 30,
                          ),
                        )
                      : null,
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                enabled: !_isLoading,
              ),
            ),
          ),

          const SizedBox(width: 8.0),

          // 🔊 Voice Button
          // 🔊 Voice Icon Button (Static, No Speech Plugin)
          Tooltip(
            message: _isListening ? 'Stop Listening' : 'Start Voice Input',
            child: GestureDetector(
              onTap: () {
                if (_isListening) {
                  _stopListening();
                  Navigator.of(context).pop(); // close the dialog if open
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Understood.'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                } else {
                  _startListening();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => FaloListeningDialog(
                      onStop: () {
                        _stopListening();
                      },
                    ),
                  );
                }
              },
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 1.0,
                  end: _isListening ? 1.2 : 1.0,
                ),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: _isListening
                            ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 1.5,
                          ),
                        ]
                            : [],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: _isListening
                          ? Lottie.asset(
                        'images/robo.json',
                        fit: BoxFit.cover,
                        repeat: true,
                        animate: true,
                      )
                          : Icon(
                        Icons.mic_none,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 8.0),

          // 📤 Send Button
          Tooltip(
            message: 'Send Analysis Request',
            child: GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: AnimatedBuilder(
                  animation: _sendButtonController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 - (_sendButtonController.value * 0.2),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(theme.disabledColor),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 28,
                          ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void _addMessageToList(ChatMessage message, {int delay = 0}) {
    if (!mounted) return;

    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;

      setState(() {
        _messages.add(message);
      });

      _scrollToBottom(delayMilliseconds: 100);
    });
  }

  void _removeLoadingMessage() {
    if (!mounted) return;

    setState(() {
      final loadingIndex =
          _messages.indexWhere((m) => m.type == MessageType.loading);
      if (loadingIndex != -1) {
        _messages.removeAt(loadingIndex);
      }
    });
  }

  void _scrollToBottom({int delayMilliseconds = 100}) {
    if (!mounted) return;
    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleError(dynamic e) {
    String errorMessageText;
    if (e is FormatException) {
      errorMessageText = "Error: Received invalid data format from server.";
    } else if (e is TimeoutException) {
      errorMessageText = "Error: Request timed out. Please try again.";
    } else if (e is SocketException) {
      errorMessageText = "Error: Cannot connect to server.";
    } else if (e is HttpException) {
      errorMessageText = "Error: ${e.message}";
    } else {
      errorMessageText = "An unexpected error occurred. Please try again.";
    }

    final errorMessage = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.error,
      text: errorMessageText,
      sessionId: _currentSessionId,
    );
    _addMessageToList(errorMessage);
  }
}
