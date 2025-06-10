// lib/widgets/animated_section.dart
// (Keep the code from the previous answer)
import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double verticalOffsetStart;
  final double horizontalOffsetStart;

  const AnimatedSection({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500), // Default duration
    this.verticalOffsetStart = 0.2, // Start slightly lower
    this.horizontalOffsetStart = 0.0, // Default no horizontal offset
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Fade Animation (Opacity)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Slide Animation (Offset)
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.horizontalOffsetStart, widget.verticalOffsetStart),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart), // Smoother curve
    );

    // Start animation after the specified delay
    _timer = Timer(widget.delay, () {
      if (mounted) { // Check if widget is still in the tree
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer if widget is disposed before it fires
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}