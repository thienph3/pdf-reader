import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../main.dart';
import 'book_list_screen.dart';
import 'category_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              const BookListScreen(),
              const CategoryScreen(),
              const StatsScreen(),
              SettingsScreen(settingsService: SettingsScope.of(context)),
            ],
          ),
        ),
        NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.library_books_outlined),
              selectedIcon: const Icon(Icons.library_books),
              label: s.library,
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_outlined),
              selectedIcon: const Icon(Icons.folder),
              label: s.categories,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: s.statistics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: s.settings,
            ),
          ],
        ),
      ],
    );
  }
}
