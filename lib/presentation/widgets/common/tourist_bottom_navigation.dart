import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom navigation bar for tourists
class TouristBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TouristBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: 'Main navigation',
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: AppTheme.accessibleLineHeight,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: AppTheme.accessibleLineHeight,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Semantics(
              label: currentIndex == 0 ? 'Home, selected' : 'Home',
              child: const Icon(Icons.home),
            ),
            label: 'Home',
            tooltip: 'Navigate to Home',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: currentIndex == 1 ? 'My Tours, selected' : 'My Tours',
              child: const Icon(Icons.tour),
            ),
            label: 'My Tours',
            tooltip: 'Navigate to My Tours',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: currentIndex == 2 ? 'Join Tour, selected' : 'Join Tour',
              child: const Icon(Icons.add_circle_outline),
            ),
            label: 'Join Tour',
            tooltip: 'Navigate to Join Tour',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: currentIndex == 3 ? 'Documents, selected' : 'Documents',
              child: const Icon(Icons.folder),
            ),
            label: 'Documents',
            tooltip: 'Navigate to Documents',
          ),
        ],
      ),
    );
  }
}
