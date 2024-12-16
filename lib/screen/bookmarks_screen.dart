import 'package:flutter/material.dart';
import '../models/article.dart';
import '../service/bookmark_service.dart';
import 'article_detail_screen.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'), // Display the screen title in the AppBar
      ),
      body: Consumer<BookmarkState>(
        builder: (context, bookmarkState, child) {
          if (!bookmarkState.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final bookmarkedArticles = bookmarkState.bookmarkedArticles;
          
          if (bookmarkedArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Bookmarks Yet', // Informational text for empty bookmarks
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Articles you bookmark will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            );
          }
          // Display the list of bookmarked articles
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: bookmarkedArticles.length,
            itemBuilder: (context, index) => _buildArticleCard(context, bookmarkedArticles[index]),
          );
        },
      ),
    );
  }
  // Format the publication date to a human-readable format
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
  // Build a card for each bookmarked article
  Widget _buildArticleCard(BuildContext context, Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to the detailed view of the article
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the article's image, if available
            Stack(
              children: [
                Container(
                  height: article.urlToImage != null ? 200 : 0,
                  decoration: article.urlToImage != null ? BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(article.urlToImage!),
                      fit: BoxFit.cover,
                      onError: (_, __) {},  // Handle image loading errors
                    ),
                  ) : null,
                ),
                if (article.urlToImage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Toggle the bookmark state of the article
                          context.read<BookmarkState>().toggleBookmark(article);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.bookmark,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (article.source != null)
                        Expanded(
                          child: Text(
                            article.source!.toUpperCase(),  // Show the source name in uppercase
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (article.publishedAt != null)
                        Text(
                          _formatDate(article.publishedAt!),  // Display formatted publication date
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
