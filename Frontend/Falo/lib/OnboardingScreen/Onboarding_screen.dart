import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui';

import '../screens/chat_screen.dart'; // For ImageFilter if adding blur effect

// import '../constants.dart'; // For SharedPreferences key
// import 'ChatScreen.dart'; // Navigate to ChatScreen


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin { // Added TickerProviderStateMixin for potential animations
  final PageController _pageController = PageController();
  bool onboardingCompleteKey=false;
  int _currentPage = 0;

  // --- Use Refined Onboarding Content ---
  final List<Map<String, String>> _onboardingPages = [
    {
      'animation': 'images/robo.json', // Verify path
      'title': 'Welcome to Falo!',
      'description': 'Your intelligent shield against misinformation. Analyze text and websites with confidence.',
    },
    {
      'animation': 'images/analyze.json', // Verify path
      'title': 'Analyze Anything, Instantly',
      'description': 'Paste text or a URL. Falo assesses credibility, checks safety, and detects potential bias in seconds.',
    },
    {
      'animation': 'images/staysafe.json',
      'title': 'Stay Informed, Stay Safe',
      'description': 'In a world of misinformation, Falo is your reliable guide to safe, verified knowledge.',
    }

  ];

  // Animation controller for text fade-in (optional, adds polish)
  late AnimationController _textAnimController;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _textAnimController = AnimationController(
      duration: const Duration(milliseconds: 600), // Duration for text fade/slide
      vsync: this,
    );
    _textFadeAnimation = CurvedAnimation(parent: _textAnimController, curve: Curves.easeIn);

    // Start animation for the first page
    _textAnimController.forward();

    _pageController.addListener(() {
      // Reset and restart animation when page changes significantly
      if (_pageController.page?.round() != _currentPage) {
        // Optional: Add animation reset logic if needed, but PageView handles transitions well.
        // _textAnimController.reset();
        // _textAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  // --- Function to complete onboarding ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLastPage = _currentPage == _onboardingPages.length - 1;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Skip Button ---
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 12.0),
                child: TextButton(
                  onPressed: () {
                    // Skip to chat screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant.withOpacity(0.8), // Subtle color
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('SKIP'),
                ),
              ),
            ),

            // --- PageView Area ---
            Expanded(
              flex: 7, // Give more space to content+animation
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  // Trigger text animation on page change
                  _textAnimController.reset();
                  _textAnimController.forward();
                },
                itemBuilder: (context, index) {
                  final page = _onboardingPages[index];
                  return _OnboardingPageContent( // Use a dedicated widget for page content
                    animationPath: page['animation']!,
                    title: page['title']!,
                    description: page['description']!,
                    textFadeAnimation: _textFadeAnimation, // Pass animation
                  );
                },
              ),
            ),

            // Add a Spacer for flexible spacing
            const Spacer(flex: 1),

            // --- Bottom Controls Area ---
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.06, 10, screenWidth * 0.06, screenHeight * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // Vertically center indicator and button
                children: [
                  // --- Smooth Page Indicator ---
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingPages.length,
                    effect: WormEffect( // WormEffect is smooth and professional
                      activeDotColor: colorScheme.primary,
                      dotColor: colorScheme.primary.withOpacity(0.3),
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 12, // Increase spacing
                      type: WormType.thin, // Use thin type for sleek look
                    ),
                    onDotClicked: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeInOutExpo, // Smoother curve
                      );
                    },
                  ),

                  // --- Next / Get Started Button ---
                  ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingPages.length - 1) {
                          // Navigate to chat screen if on last page
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
                          );
                        } else {
                          // Go to next page
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15), // Generous padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Fully rounded ends
                      ),
                      elevation: 4, // Add elevation for depth
                      shadowColor: colorScheme.primary.withOpacity(0.3), // Subtle shadow matching button color
                    ),
                    child: AnimatedSwitcher( // Animate the text change
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Text(
                        isLastPage ? 'GET STARTED' : 'NEXT',
                        key: ValueKey<bool>(isLastPage), // Key for the switcher
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8, // Add letter spacing
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widget for Page Content (Includes Animation) ---
class _OnboardingPageContent extends StatelessWidget {
  final String animationPath;
  final String title;
  final String description;
  final Animation<double> textFadeAnimation; // Receive animation

  const _OnboardingPageContent({
    required this.animationPath,
    required this.title,
    required this.description,
    required this.textFadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- Lottie Animation ---
          Expanded(
            flex: 5, // Animation gets more space
            child: Lottie.asset(
              animationPath,
              fit: BoxFit.contain,
              height: screenHeight * 0.35, // Responsive height
              errorBuilder: (context, error, stackTrace) => Center(child: Text("Animation Error\n$error")),
            ),
          ),
          const SizedBox(height: 30), // Adjust spacing as needed

          // --- Animated Text Content ---
          Expanded(
            flex: 3, // Text gets less space
            child: FadeTransition( // Apply fade animation to text block
              opacity: textFadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // --- Title ---
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      height: 1.3, // Adjust line height for title
                    ),
                  ),
                  const SizedBox(height: 18),

                  // --- Description ---
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.8),
                      height: 1.6, // Increase line spacing for readability
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}