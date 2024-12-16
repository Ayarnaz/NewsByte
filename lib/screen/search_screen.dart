import 'package:flutter/material.dart';
import '../models/article.dart';
import '../service/http_service.dart';
import 'article_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final HttpService _httpService = HttpService();
  final TextEditingController _searchController = TextEditingController(); // Controller for the search input
  List<Article> searchResults = []; // List to hold search results
  List<Article> trendingArticles = []; // List to hold trending articles
  bool isLoading = false; // Boolean to handle loading state
  String? sortBy = 'publishedAt'; // Default sorting option
  String searchIn = 'title,description,content'; // Fields to search in
  // List of predefined trending topics
  final List<String> trendingTopics = [
    'Technology',
    'Climate',
    'Business',
    'Sports',
    'Health',
    'Politics',
  ];

  @override
  void initState() {
    super.initState();
    _loadTrendingNews();  // Load trending news on initialization
  }

  @override
  void dispose() {
    _searchController.dispose();  // Dispose controller when not needed
    super.dispose();
  }

  Future<void> _loadTrendingNews() async {
    try {
      final response = await _httpService.getTopHeadlines();  // Fetch trending articles
      setState(() {
        trendingArticles = (response['articles'] as List) // Convert response to Article model
            .map((article) => Article.fromJson(article))
            .take(3)  // Take only the top 3 articles
            .toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;  // Do nothing if query is empty

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _httpService.searchNews(
        query: query,
        sortBy: sortBy,
        searchIn: searchIn,
      );
      
      setState(() {
        searchResults = (response['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }
  // Widget to build individual article cards
  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
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
              // Image or default icon for article
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
              // Article text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.source != null)
                      // Display article source if available
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Article title
                      Text(
                        article.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article.publishedAt != null
                            ? _formatDate(article.publishedAt!)
                            : '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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
  // Function to format date into readable format
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
  // Function to show sorting options in a bottom sheet
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
              // Sort options
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Latest'),
                selected: sortBy == 'publishedAt',
                onTap: () {
                  setState(() => sortBy = 'publishedAt');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Popularity'),
                selected: sortBy == 'popularity',
                onTap: () {
                  setState(() => sortBy = 'popularity');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Relevance'),
                selected: sortBy == 'relevancy',
                onTap: () {
                  setState(() => sortBy = 'relevancy');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // Function to show search filter options in a bottom sheet
  void _showSearchFilterOptions() {
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
                  'Search In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Filter options
              ListTile(
                title: const Text('All Fields'),
                selected: searchIn == 'title,description,content',
                onTap: () {
                  setState(() => searchIn = 'title,description,content');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Title Only'),
                selected: searchIn == 'title',
                onTap: () {
                  setState(() => searchIn = 'title');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Description Only'),
                selected: searchIn == 'description',
                onTap: () {
                  setState(() => searchIn = 'description');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Content Only'),
                selected: searchIn == 'content',
                onTap: () {
                  setState(() => searchIn = 'content');
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingTopicChip(String topic) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: ActionChip(
        label: Text(
          topic,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onPressed: () => _performSearch(topic),
      ),
    );
  }
  // Main UI for SearchScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Header with Back Button and Sort
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: _showSearchFilterOptions,
                      ),
                      IconButton(
                        icon: const Icon(Icons.sort),
                        onPressed: _showSortOptions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search news...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchResults.clear();
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                ],
              ),
            ),
            // Trending Topics
            if (searchResults.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trending Topics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      children: trendingTopics.map((topic) => _buildTrendingTopicChip(topic)).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (trendingArticles.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Trending News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...trendingArticles.map(_buildArticleCard),
              ],
            ],
            // Search Results
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildArticleCard(searchResults[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 