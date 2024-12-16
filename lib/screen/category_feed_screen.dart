import 'package:flutter/material.dart';
import '../models/article.dart';
import '../service/http_service.dart';
import 'article_detail_screen.dart';

class CategoryFeedScreen extends StatefulWidget {
  final String category;  // Name of the category to display news for
  final bool isHeadlines; // Flag to check if it's a headline feed

  const CategoryFeedScreen({
    super.key,
    required this.category,
    this.isHeadlines = false,
  });

  @override
  State<CategoryFeedScreen> createState() => _CategoryFeedScreenState();
}

class _CategoryFeedScreenState extends State<CategoryFeedScreen> {
  final HttpService _httpService = HttpService(); // API service for fetching articles
  List<Article> articles = [];  // List to store fetched articles
  bool isLoading = true;  // Track loading state
  String? sortBy = 'publishedAt';

  @override
  void initState() {
    super.initState();
    _loadCategoryNews();  // Load articles when the screen is initialized
  }

  // Fetch articles based on the category or headlines
  Future<void> _loadCategoryNews() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Decide the API method based on whether it's a headline or category feed
      final response = widget.isHeadlines
          ? await _httpService.getTopHeadlines()
          : await _httpService.getAllNews(
              sortBy: sortBy,
              query: widget.category,
            );
      
      setState(() {
        // Filter articles to include only those with valid data
        articles = (response['articles'] as List)
            .map((article) => Article.fromJson(article))
            .where((article) => 
                article.title != null &&
                article.title!.isNotEmpty &&
                article.title != '[Removed]' &&
                article.urlToImage != null)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        articles = [];  // Clear articles on error
      });
    }
  }

  void _showSortOptions() {
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
                  'Sort By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Latest'),
                selected: sortBy == 'publishedAt',
                onTap: () {
                  setState(() {
                    sortBy = 'publishedAt';
                    isLoading = true;
                  });
                  Navigator.pop(context);
                  _loadCategoryNews();  // Reload articles with new sort order
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Popularity'),
                selected: sortBy == 'popularity',
                onTap: () {
                  setState(() {
                    sortBy = 'popularity';
                    isLoading = true;
                  });
                  Navigator.pop(context);
                  _loadCategoryNews();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // Build a card UI for each article
  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to the article detail screen when tapped
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
            if (article.urlToImage != null)
              Hero(
                tag: article.urlToImage!,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(article.urlToImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                            article.source!.toUpperCase(),
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
                          _formatDate(article.publishedAt!),
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
  // Format the publication date for display
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHeadlines ? 'Top Headlines' : widget.category),
        actions: [
          if (!widget.isHeadlines)
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortOptions,  // Show sorting options
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Articles Available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unable to fetch articles.\nPlease check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadCategoryNews,
                        child: const Text('Retry'), // Retry loading articles
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategoryNews, // Enable pull-to-refresh functionality
                  child: ListView(
                    children: [
                      ...articles.map((article) => _buildArticleCard(article)),
                    ],
                  ),
                ),
    );
  }
} 
