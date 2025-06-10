import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:anewdehli12/models/chat_message.dart';
import 'package:anewdehli12/widgets/bot_response_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Animation<double> animation;

  const MessageBubble({
    super.key,
    required this.message,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message.type == MessageType.user;
    final isError = message.type == MessageType.error;
    final isLoading = message.type == MessageType.loading;

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    Color bubbleColor;
    Color textColor;
    if (isUser) {
      bubbleColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isError) {
      bubbleColor = colorScheme.errorContainer ?? colorScheme.error.withOpacity(0.7);
      textColor = colorScheme.onErrorContainer ?? colorScheme.onError;
    } else if (isLoading) {
      bubbleColor = colorScheme.surfaceVariant.withOpacity(0.5);
      textColor = colorScheme.onSurfaceVariant;
    } else {
      bubbleColor = colorScheme.secondary;
      textColor = colorScheme.onSecondary;
    }

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    Widget messageContent;
    if (isLoading) {
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'images/robo.json',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "Analyzing your message...",
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      );
    } else if (isUser || isError) {
      messageContent = Text(
        message.text ?? "...",
        style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
      );
    } else {
      if (message.botResponseData != null && message.botResponseData!.isNotEmpty) {
        messageContent = BotResponseCard(data: message.botResponseData!);
      } else {
        messageContent = Text(
          message.text ?? "[Analysis Received]",
          style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
        );
      }
    }

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuart,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SizeTransition(
        sizeFactor: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isUser ? 0.6 : -0.6, 0.2),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: Align(
            alignment: alignment,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80),
              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRect(child: messageContent),
            ),
          ),
        ),
      ),
    );
  }
}