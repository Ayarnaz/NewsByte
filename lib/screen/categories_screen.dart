import 'package:flutter/material.dart';
import 'category_feed_screen.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({super.key});

  // List of categories with their names and corresponding image paths
  final List<Map<String, String>> categories = [
    {
      'name': 'Politics',
      'image': 'assets/images/politics.jpg',
    },
    {
      'name': 'Current Events',
      'image': 'assets/images/current_events.jpg',
    },
    {
      'name': 'Business',
      'image': 'assets/images/business.jpg',
    },
    {
      'name': 'Technology',
      'image': 'assets/images/technology.jpg',
    },
    {
      'name': 'Sports',
      'image': 'assets/images/sports.jpg',
    },
    {
      'name': 'Entertainment',
      'image': 'assets/images/entertainment.jpg',
    },
    {
      'name': 'Health',
      'image': 'assets/images/health.jpg',
    },
    {
      'name': 'Science',
      'image': 'assets/images/science.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length, // Total number of categories
        itemBuilder: (context, index) {
          final category = categories[index]; // Get the category at the current index
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryFeedScreen(
                    category: category['name']!,  // Pass the category name
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(category['image']!),  // Category image
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    category['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 