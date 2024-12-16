import 'package:flutter/material.dart';
import '../models/article.dart';
import '../service/bookmark_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../service/reading_history_service.dart';
import 'article_web_view_screen.dart';
import '../widgets/article_card.dart';
import 'package:provider/provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});
  // Share the article details using the Share package.
  void _shareArticle(BuildContext context) {
    final String shareText = '''${article.title}

${article.description}

Read more: ${article.url}''';

    Share.share(
      shareText,
      subject: article.title,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 10, 10),
    );
  }
  // Display a modal bottom sheet for sharing options, including general sharing and copying the link.
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Share via',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF0B86E7)),
                title: const Text('General Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareArticle(context);
                },
              ),
              if (article.url != null)
                ListTile(
                  leading: const Icon(Icons.copy, color: Color(0xFF0B86E7)),
                  title: const Text('Copy Link'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: article.url!));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add the article to the reading history when the screen is loaded.
    Provider.of<ReadingHistoryState>(context, listen: false).addToHistory(article);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(article.source ?? 'News Detail'),
        actions: [
          // Share button to trigger sharing options
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOptions(context),
          ),
          // Bookmark button toggles bookmark state for the article.
          Consumer<BookmarkState>(
            builder: (context, bookmarkState, child) {
              final isBookmarked = bookmarkState.isBookmarked(article.url ?? '');
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
                ),
                onPressed: () async {
                  await bookmarkState.toggleBookmark(article);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display the article details using a reusable ArticleCard widget.
          Expanded(
            child: ArticleCard(article: article),
          ),
          if (article.url != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: () {
                  // Open the original article in a WebView screen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleWebViewScreen(
                        url: article.url!,
                        title: article.title ?? 'Article',
                      ),
                    ),
                  );
                },
                child: const Text('View Original Article'),
              ),
            ),
        ],
      ),
    );
  }
}