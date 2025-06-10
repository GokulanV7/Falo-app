import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'animated_section.dart'; // For clamping score and min function
import 'package:url_launcher/url_launcher.dart'; // Add this import

// Adjust package name if needed

class BotResponseCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BotResponseCard({super.key, required this.data});

  // --- Helper to Check Value Presence --- (Keep as is)
  bool _hasValue(dynamic value, {bool treatZeroAsEmpty = false}) {
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    if (value is List && value.isEmpty) return false;
    if (value is Map && value.isEmpty) return false;
    if (treatZeroAsEmpty && value is num && value == 0) return false;
    return true;
  }

  // --- Color Helpers (Now rely solely on theme) ---
  Color _getAssessmentColor(String? assessment, ThemeData theme) {
    final String lowerCaseAssessment = (assessment ?? '').toLowerCase();
    // Use theme colors directly
    if (lowerCaseAssessment.contains("misleading") ||
        lowerCaseAssessment.contains("misinformation") ||
        lowerCaseAssessment.contains("malicious") ||
        lowerCaseAssessment.contains("phishing") ||
        lowerCaseAssessment.contains("dangerous")) {
      return theme.colorScheme.error;
    } else if (lowerCaseAssessment.contains("suspicious") ||
        lowerCaseAssessment.contains("risky") ||
        lowerCaseAssessment.contains("potential")) {
      return Colors.orangeAccent[400] ??
          Colors
              .orange; // Keep orange for warning if no theme equivalent desired
    } else if (lowerCaseAssessment.contains("likely safe") ||
        lowerCaseAssessment.contains("safe") ||
        lowerCaseAssessment.contains("harmless") ||
        lowerCaseAssessment.contains("low_risk") ||
        lowerCaseAssessment.contains("likely factual") ||
        lowerCaseAssessment.contains("factual")) {
      return Colors
          .green; // Keep green for success if no theme equivalent desired
    } else if (lowerCaseAssessment.contains("uncertain") ||
        lowerCaseAssessment.contains("unverified")) {
      return theme.colorScheme.onSurface.withOpacity(
        0.6,
      ); // Use a muted onSurface color
    }
    return theme.colorScheme.secondary.withOpacity(0.8); // Fallback using theme
  }

  Color _getConfidenceColor(dynamic scoreValue, ThemeData theme) {
    double score = _parseConfidenceScore(scoreValue);
    // Use theme/standard colors
    if (score < 0.4) return theme.colorScheme.error;
    if (score < 0.7)
      return Colors.orangeAccent[400] ??
          Colors.orange; // Keep orange for warning
    return Colors.green; // Keep green for success
  }

  // --- Data Parsing Helpers --- (Keep as is)
  double _parseConfidenceScore(dynamic scoreValue) {
    double score = 0.0;
    if (scoreValue is double)
      score = scoreValue;
    else if (scoreValue is int)
      score = scoreValue.toDouble();
    else if (scoreValue is String)
      score = double.tryParse(scoreValue.replaceAll('%', '')) ?? 0.0;
    if (score > 1.0) score = score / 100.0;
    return score.clamp(0.0, 1.0);
  }

  dynamic _getNestedValue(List<String> keys) {
    dynamic current = data;
    for (String key in keys) {
      if (current is Map && current.containsKey(key) && current[key] != null) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  // --- URL Launcher Function ---
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  // --- Function to convert URLs in text to clickable links ---
  Widget _buildTextWithLinks(BuildContext context, String text, TextStyle? style) {
    final theme = Theme.of(context);

    // Regex to identify URLs in text
    final RegExp urlRegExp = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    final List<InlineSpan> textSpans = [];
    int lastMatchEnd = 0;

    // Find all URL matches in the text
    for (final Match match in urlRegExp.allMatches(text)) {
      final String url = match.group(0)!;
      final int start = match.start;
      final int end = match.end;

      // Add text before the URL
      if (start > lastMatchEnd) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, start),
            style: style,
          ),
        );
      }

      // Add the URL as a clickable text span
      textSpans.add(
        TextSpan(
          text: url,
          style: style?.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ),
      );

      lastMatchEnd = end;
    }

    // Add any remaining text after the last URL
    if (lastMatchEnd < text.length) {
      textSpans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: style,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final colorScheme = theme.colorScheme; // Get the color scheme
    int animationIndex = 0;
    List<Widget> sections = [];

    // addAnimatedSection helper remains the same

    void addAnimatedSection(Widget? contentWidget) {
      if (contentWidget != null) {
        sections.add(
          AnimatedSection(
            delay: Duration(milliseconds: 80 + (animationIndex++ * 100)),
            duration: const Duration(milliseconds: 450),
            verticalOffsetStart: 0.18,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: contentWidget,
            ),
          ),
        );
      }
    }

    // --- Build Sections (Using Theme Colors) ---

    // 1. Input Text
    final inputText = data['input_text'];
    if (_hasValue(inputText)) {
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'Input',
          // Use onSecondary color as this card sits on the secondary background
          child: Text(
            inputText,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    // 2. Overall Assessment
    final assessment = data['assessment'];
    if (_hasValue(assessment)) {
      final Color assessmentColor = _getAssessmentColor(assessment, theme);
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'Assessment',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                // Use assessment color with opacity relative to bubble background
                color: assessmentColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: assessmentColor.withOpacity(0.7),
                  width: 1.2,
                ),
              ),
              child: Text(
                assessment,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: assessmentColor,
                ),
              ), // Text color is the direct assessment color
            ),
          ),
        ),
      );
    }

    // 3. Confidence Score
    final confidenceScoreValue = data['confidence_score'];
    if (_hasValue(confidenceScoreValue)) {
      double score = _parseConfidenceScore(confidenceScoreValue);
      Color confidenceColor = _getConfidenceColor(score, theme);
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'Confidence Score',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: score),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                  builder:
                      (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4.5,
                    // Background uses onSecondary color with low opacity
                    backgroundColor: colorScheme.onSecondary.withOpacity(
                      0.15,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      confidenceColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(score * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: confidenceColor,
                ),
              ), // Text color is the confidence color
            ],
          ),
        ),
      );
    }

    // 4. Explanation OR Answer
    final explanation = data['explanation'];
    final answer = data['answer'];
    String? displayText;
    if (_hasValue(explanation)) {
      displayText = explanation;
    } else if (_hasValue(answer)) {
      displayText = answer;
    }

    if (_hasValue(displayText)) {
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'Explanation',
          child: _buildTextWithLinks(
            context,
            displayText!,
            theme.textTheme.bodyLarge?.copyWith(
              // Use slightly brighter onSecondary for main text
              color: colorScheme.onSecondary.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // 5. Evidence
    final evidenceList = data['evidence'];
    if (evidenceList is List && evidenceList.isNotEmpty) {
      List<Widget> evidenceWidgets = [];
      for (var item in evidenceList) {
        if (item is Map) {
          final source = item['source'];
          final snippet = item['snippet'];
          if (_hasValue(snippet)) {
            evidenceWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasValue(source))
                      GestureDetector(
                        onTap: () {
                          if (source is String && source.startsWith('http')) {
                            _launchURL(source);
                          }
                        },
                        child: Text(
                          "Source: $source",
                          style: theme.textTheme.labelSmall?.copyWith(
                            // Use primary color for clickable source
                            color: source is String && source.startsWith('http')
                                ? theme.colorScheme.primary
                                : theme.hintColor.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            decoration: source is String && source.startsWith('http')
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ),
                    if (_hasValue(source)) const SizedBox(height: 4),
                    _buildTextWithLinks(
                      context,
                      snippet,
                      theme.textTheme.bodyMedium?.copyWith(
                        // Use standard onSecondary color for snippet
                        color: colorScheme.onSecondary.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      }
      if (evidenceWidgets.isNotEmpty) {
        addAnimatedSection(
          _buildSectionContent(
            theme: theme,
            title: 'Evidence',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: evidenceWidgets,
            ),
          ),
        );
      }
    }

    // --- URL Scan Sections (Using Theme Colors) ---

    // 6. Scanned URL Display
    final scannedUrl = data['scanned_url'];
    if (_hasValue(scannedUrl)) {
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'Scanned URL',
          // Make scanned URL clickable
          child: GestureDetector(
            onTap: () => _launchURL(scannedUrl),
            child: Text(
              scannedUrl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }

    // 7. VirusTotal Scan Results
    final vtDetails = _getNestedValue([
      'scan_results',
      'virustotal',
      'details',
    ]);
    List<Widget> vtContentWidgets = [];
    if (vtDetails is Map) {
      final vtAssessment = vtDetails['assessment'];
      if (_hasValue(vtAssessment)) {
        final Color vtColor = _getAssessmentColor(vtAssessment, theme);
        // Pass theme to helper
        vtContentWidgets.add(
          _buildDetailRow(
            theme,
            'VT Status:',
            vtAssessment,
            valueColor: vtColor,
            isBold: true,
          ),
        );
      }
      final mCount = vtDetails['malicious_count'];
      final sCount = vtDetails['suspicious_count'];
      final hCount = vtDetails['harmless_count'];
      if (_hasValue(mCount, treatZeroAsEmpty: false) ||
          _hasValue(sCount, treatZeroAsEmpty: false) ||
          _hasValue(hCount, treatZeroAsEmpty: false)) {
        vtContentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: [
                // Pass theme to helper, use theme error color
                if (_hasValue(mCount, treatZeroAsEmpty: true))
                  _buildCountChip(
                    theme,
                    icon: Icons.bug_report_outlined,
                    label: 'Malicious',
                    count: mCount,
                    color: colorScheme.error,
                  ),
                // Keep orange for warning
                if (_hasValue(sCount, treatZeroAsEmpty: true))
                  _buildCountChip(
                    theme,
                    icon: Icons.help_outline_rounded,
                    label: 'Suspicious',
                    count: sCount,
                    color: Colors.orangeAccent,
                  ),
                // Keep green for success
                if (_hasValue(hCount, treatZeroAsEmpty: true))
                  _buildCountChip(
                    theme,
                    icon: Icons.verified_user_outlined,
                    label: 'Harmless',
                    count: hCount,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        );
      }
      final vtCategories = vtDetails['categories'];
      if (vtCategories is Map && vtCategories.isNotEmpty) {
        List<Widget> categoryChips = [];
        vtCategories.forEach((vendor, category) {
          if (_hasValue(category)) {
            categoryChips.add(
              Chip(
                label: Text(category),
                // Use theme's hint color for avatar text
                avatar: Text(
                  vendor.substring(0, min<int>(vendor.length, 2)).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                    fontSize: 9,
                  ),
                ),
                // Use theme surfaceVariant or similar for background
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.6),
                // Use theme onSurfaceVariant or onSecondary for label
                labelStyle: TextStyle(
                  color:
                  colorScheme.onSurfaceVariant ??
                      colorScheme.onSecondary.withOpacity(0.85),
                  fontSize: 11.5,
                ),
                // Use theme's chip theme for padding etc.
                padding: theme.chipTheme.padding,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            );
          }
        });
        if (categoryChips.isNotEmpty) {
          vtContentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use theme label style for title
                  Text(
                    "VT Categories:",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(spacing: 6.0, runSpacing: 4.0, children: categoryChips),
                ],
              ),
            ),
          );
        }
      }
    }
    if (vtContentWidgets.isNotEmpty) {
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'VirusTotal Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: vtContentWidgets,
          ),
        ),
      );
    }

    // 8. IPQualityScore Scan Results
    final ipqsDetails = _getNestedValue([
      'scan_results',
      'ipqualityscore',
      'details',
    ]);
    List<Widget> ipqsContentWidgets = [];
    if (ipqsDetails is Map) {
      final ipqsCategory = ipqsDetails['assessment_category'];
      if (_hasValue(ipqsCategory)) {
        final Color ipqsColor = _getAssessmentColor(ipqsCategory, theme);
        // Pass theme to helper
        ipqsContentWidgets.add(
          _buildDetailRow(
            theme,
            'IPQS Risk:',
            ipqsCategory,
            valueColor: ipqsColor,
            isBold: true,
          ),
        );
      }
      final Map<String, IconData> flags = {
        'Phishing': Icons.phishing_rounded,
        'Malware': Icons.bug_report_rounded,
        'Spam': Icons.mark_email_read_outlined,
        'Suspicious': Icons.help_outline_rounded,
      };
      List<Widget> flagIndicators = [];
      flags.forEach((label, icon) {
        final key = 'is_${label.toLowerCase()}';
        if (ipqsDetails.containsKey(key) && ipqsDetails[key] == true) {
          // Pass theme to helper
          flagIndicators.add(
            _buildBooleanIndicator(
              theme,
              icon: icon,
              label: label,
              isTrue: true,
            ),
          );
        }
      });
      if (flagIndicators.isNotEmpty) {
        ipqsContentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Wrap(
              spacing: 15.0,
              runSpacing: 8.0,
              children: flagIndicators,
            ),
          ),
        );
      }
    }
    if (ipqsContentWidgets.isNotEmpty) {
      addAnimatedSection(
        _buildSectionContent(
          theme: theme,
          title: 'IPQualityScore Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ipqsContentWidgets,
          ),
        ),
      );
    }

    // --- Return ---
    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          // Use theme color for fallback text
          child: Text(
            "[No analysis details available]",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSecondary.withOpacity(0.6),
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  // --- Helper Widgets (Pass Theme, Use Theme Colors) ---
  Widget _buildSectionContent({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            // Use hintColor from theme for section titles
            color: theme.hintColor.withOpacity(0.85),
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }

  Widget _buildDetailRow(
      ThemeData theme,
      String label,
      String value, {
        Color? valueColor,
        bool isBold = false,
      }) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              // Use onSecondary color with opacity for label
              color: colorScheme.onSecondary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                // Use passed valueColor or default to onSecondary
                color: valueColor ?? colorScheme.onSecondary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(
      ThemeData theme, {
        required IconData icon,
        required int count,
        required String label,
        required Color color,
      }) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Use the provided color (error, orange, green) with opacity
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        // Use the provided color for border too
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: theme.textTheme.bodySmall?.copyWith(
              // Text color is the direct status color
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanIndicator(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required bool isTrue,
      }) {
    final colorScheme = theme.colorScheme;
    // Use theme error color if true, otherwise green
    final Color color = isTrue ? colorScheme.error : Colors.green;
    final String text = isTrue ? '$label Detected' : 'Not $label';
    final IconData displayIcon = isTrue ? icon : Icons.check_circle_outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(displayIcon, size: 15, color: color.withOpacity(0.8)),
        const SizedBox(width: 5),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            // Text color matches the status color
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}