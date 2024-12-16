import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/reading_history_service.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({super.key});

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  // Builds a dismissible article card with swipe-to-delete functionality
  Widget _buildArticleCard(BuildContext context, Article article) {
    return Dismissible(
      key: Key(article.url ?? ''),  // Unique key for each article
      background: Container(
        color: Colors.red,  // Background color for the dismiss action
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart, // Allow swipe only from right to left
      onDismissed: (direction) {
        Provider.of<ReadingHistoryState>(context, listen: false)
            .removeFromHistory(article);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailScreen(article: article),
              ),
            );
          },
          leading: article.urlToImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.urlToImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.newspaper,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Icon(Icons.newspaper),
          title: Text(
            article.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${article.source ?? 'Unknown'} • ${_formatDate(article.publishedAt ?? DateTime.now().toString())}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Show a confirmation dialog to clear reading history
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear your reading history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),  // Dismiss dialog
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<ReadingHistoryState>(context, listen: false)
                            .clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('CLEAR'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReadingHistoryState>(
        builder: (context, historyState, child) {
          final readArticles = historyState.readArticles;
          // If no reading history, show an empty state
          if (readArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Reading History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Articles you read will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Swipe left on articles to remove them from history',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            );
          }
          // Display a list of articles in reading history
          return ListView.builder(
            itemCount: readArticles.length,
            itemBuilder: (context, index) => _buildArticleCard(context, readArticles[index]),
          );
        },
      ),
    );
  }
} 