import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../theme_notifier.dart';

class ProfessionalAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ProfessionalAppBar({super.key});

  @override
  State<ProfessionalAppBar> createState() => _ProfessionalAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProfessionalAppBarState extends State<ProfessionalAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _circleIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color iconColor,
    required Color bgColor,
    double size = 24,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: size, color: iconColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final brightness = themeNotifier.currentTheme.brightness;
    final isDark = brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black;
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onPrimary;
    final bgColor = theme.colorScheme.primary;

    return AppBar(
      elevation: theme.appBarTheme.elevation ?? (isDark ? 1.0 : 2.0),
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: InkWell(
          onTap: _isSearching ? _toggleSearch : () => Scaffold.of(context).openDrawer(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearching
                  ? Icon(Icons.arrow_back, key: const ValueKey('back'), color: iconColor)
                  : Lottie.asset(
                'images/robo.json',
                key: const ValueKey('robo'),
                repeat: true,
                animate: true,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearching
            ? TextField(
          key: const ValueKey('searchField'),
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: titleColor.withOpacity(0.6)),
          ),
          style: TextStyle(color: titleColor, fontSize: 18),
          cursorColor: titleColor,
        )
            : AnimatedDefaultTextStyle(
          key: const ValueKey('appTitle'),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: titleColor,
              letterSpacing: 1.0,
            ),
          ),
          child: const Text('Falo'),
        ),
      ),
      centerTitle: false,
      actions: [
        if (_isSearching)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _circleIcon(
                  icon: Icons.close,
                  tooltip: 'Clear search',
                  onTap: _searchController.clear,
                  iconColor: iconColor,
                  bgColor: bgColor,
                ),
              )
                  : const SizedBox.shrink();
            },
          ),
        if (!_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _circleIcon(
              icon: Icons.search,
              tooltip: 'Search',
              onTap: _toggleSearch,
              iconColor: iconColor,
              bgColor: bgColor,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 6),
          child: Tooltip(
            message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                final newPref = isDark ? ThemePreference.light : ThemePreference.dark;
                themeNotifier.switchTheme(newPref);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    key: ValueKey(brightness),
                    size: 24,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
