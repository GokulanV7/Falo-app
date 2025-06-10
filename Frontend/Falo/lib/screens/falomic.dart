import 'package:flutter/material.dart';

class WhatsAppMicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const WhatsAppMicButton({
    Key? key,
    required this.isListening,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WhatsAppMicButton> createState() => _WhatsAppMicButtonState();
}

class _WhatsAppMicButtonState extends State<WhatsAppMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant WhatsAppMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: widget.isListening ? 'Stop Listening' : 'Start Voice Input',
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: widget.isListening ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              widget.isListening ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
