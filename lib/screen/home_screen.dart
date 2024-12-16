import 'package:flutter/material.dart';
import '../service/http_service.dart';
import '../models/article.dart';
import '../screen/article_detail_screen.dart';
import '../screen/search_screen.dart';
import '../widgets/top_headlines_carousel.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HttpService _httpService = HttpService();
  List<Article> topHeadlines = [];  // List of top headlines
  List<Article> mainFeedArticles = [];  // List of articles for the main feed
  bool isLoading = true;
  String? sortBy = 'publishedAt'; // Sorting option for articles
  Set<String> removedArticleIds = {}; // Track articles removed from the feed

  String currentCategory = 'general'; // Default news category
  final List<String> categories = [ // Available categories
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  final ScrollController _scrollController = ScrollController();
  // Shows sorting options in a bottom sheet
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
                  _loadAllNews(); // Reload articles with updated sorting
                  Navigator.pop(context);
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
                  _loadAllNews();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAllNews(); // Fetch initial set of articles on screen load
  }
  // Fetch top headlines and category-specific articles
  Future<void> _loadAllNews() async {
    if (!mounted) return;
    
    // Store the current articles for comparison
    final List<Article> oldTopHeadlines = List.from(topHeadlines);
    final List<Article> oldMainFeedArticles = List.from(mainFeedArticles);
    
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch articles from the service
      final topResponse = await _httpService.getTopHeadlines();
      final mainResponse = await _httpService.getAllNews(
        sortBy: sortBy,
        query: currentCategory
      );
      
      if (!mounted) return;
      // Parse and filter articles
      final List<Article> newTopHeadlines = (topResponse['articles'] as List)
          .map((article) => Article.fromJson(article))
          .where((article) => 
              !removedArticleIds.contains(article.url) &&
              article.title != null &&
              article.title!.isNotEmpty &&
              article.title != '[Removed]')
          .toList();
          
      final List<Article> newMainFeedArticles = (mainResponse['articles'] as List)
          .map((article) => Article.fromJson(article))
          .where((article) => 
              !removedArticleIds.contains(article.url) &&
              article.title != null &&
              article.title!.isNotEmpty &&
              article.title != '[Removed]')
          .toList();

      setState(() {
        topHeadlines = newTopHeadlines;
        mainFeedArticles = newMainFeedArticles;
        isLoading = false;
      });

      // Check if content is the same
      bool isContentSame = _areArticleListsEqual(oldTopHeadlines, newTopHeadlines) && 
                          _areArticleListsEqual(oldMainFeedArticles, newMainFeedArticles);

      if (isContentSame && oldTopHeadlines.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You\'re already up to date!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
        topHeadlines = [];
        mainFeedArticles = [];
      });
    }
  }

  // Helper method to compare two lists of articles
  bool _areArticleListsEqual(List<Article> list1, List<Article> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].url != list2[i].url) return false;
    }
    return true;
  }
  // Remove an article from both the top headlines and main feed
  void _removeArticle(Article article) {
    setState(() {
      removedArticleIds.add(article.url ?? '');
      mainFeedArticles.removeWhere((a) => a.url == article.url);
      topHeadlines.removeWhere((a) => a.url == article.url);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // Builds the UI card for displaying an article
  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to article detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          );
        },
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: article.urlToImage != null
                      ? Image.network(
                          article.urlToImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.newspaper,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              // Article Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source and Date
                      Wrap(
                        spacing: 8,
                        children: [
                          if (article.source != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                article.source!,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (article.publishedAt != null)
                            Text(
                              _formatDate(article.publishedAt!),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          article.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (article.description != null)
                        Expanded(
                          flex: 1,
                          child: Text(
                            article.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Format a date string into a human-readable format
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
  // Build a UI chip for each news category
  Widget _buildCategoryChip(String category) {
    final bool isSelected = currentCategory == category;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          category.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
        pressElevation: 0,
        onSelected: (selected) {
          setState(() {
            currentCategory = category;
            isLoading = true;
          });
          _loadAllNews();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewsByte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllNews,  // Enable pull-to-refresh
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : mainFeedArticles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to Load News',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your internet connection\nand try again',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadAllNews,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: topHeadlines.isEmpty 
                        ? mainFeedArticles.length 
                        : mainFeedArticles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0 && topHeadlines.isNotEmpty) {
                        return TopHeadlinesCarousel(
                          articles: topHeadlines,
                          scrollController: _scrollController,
                        );
                      }
                      final articleIndex = topHeadlines.isEmpty ? index : index - 1;
                      return _buildArticleCard(mainFeedArticles[articleIndex]);
                    },
                  ),
      ),
    );
  }
}
