import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;  // The Article object that will be passed to this widget
  // Constructor to receive the Article object
  const ArticleCard({
    super.key,
    required this.article,
  });

  // Method to format the date from a string to a more readable format
  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr); // Parse the date string into a DateTime object
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'; // Format as 'day/month/year hour:minute'
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Allows the content to be scrollable in case it overflows
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display image if available
          if (article.urlToImage != null)
            Hero(
              tag: article.urlToImage!,
              child: Image.network(
                article.urlToImage!,  // Load image from the network
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 250),  // If the image fails to load, show an empty box with the same height
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source and Date
                Row(
                  children: [
                    if (article.source != null) // If source is available, display it
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.source!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (article.publishedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(article.publishedAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  article.title ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // Author
                if (article.author != null) ...[
                  Text(
                    'By ${article.author}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Description
                if (article.description != null) ...[
                  Text(
                    article.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Content
                if (article.content != null)
                  Text(
                    article.content!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}