import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'bookmarks_screen.dart';
import 'reading_history_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab
  
  final List<Widget> _screens = [
    const HomeScreen(), // Home screen showing the main feed
    CategoriesScreen(), // Categories screen to browse articles by category
    const BookmarksScreen(),  // Bookmarks screen to view saved articles
    const ReadingHistoryScreen(), // Reading history screen to track viewed articles
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: 65,
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,  // Highlights the currently selected tab
        indicatorColor: const Color(0xFF0B86E7).withOpacity(0.12),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          // Navigation tab for the Home screen
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF0B86E7)),
            label: 'Home',
          ),
          // Navigation tab for Categories screen
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: Color(0xFF0B86E7)),
            label: 'Categories',
          ),
          // Navigation tab for Bookmarks screen
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark, color: Color(0xFF0B86E7)),
            label: 'Bookmarks',
          ),
          // Navigation tab for Reading History screen
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFF0B86E7)),
            label: 'History',
          ),
        ],
      ),
    );
  }
} 