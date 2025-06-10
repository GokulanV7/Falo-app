import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FaloListeningDialog extends StatelessWidget {
  final VoidCallback onStop;

  const FaloListeningDialog({super.key, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'images/robo.json',
              height: 120,
              repeat: true,
            ),
            const SizedBox(height: 16),
            Text(
              '🎧 Falo is listening...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.stop),
              label: const Text("Stop"),
              onPressed: () {
                onStop();
                Navigator.of(context).pop(); // close dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}

