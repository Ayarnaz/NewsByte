import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screen/article_detail_screen.dart';
import '../screen/category_feed_screen.dart';

class TopHeadlinesCarousel extends StatefulWidget {
  final List<Article> articles; // List of articles to display in the carousel
  final ScrollController scrollController; // Controller to manage scrolling behavior

  const TopHeadlinesCarousel({
    super.key,
    required this.articles,
    required this.scrollController,
  });

  @override
  State<TopHeadlinesCarousel> createState() => _TopHeadlinesCarouselState();
}

class _TopHeadlinesCarouselState extends State<TopHeadlinesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);  // Controller for page view, allows for fractional viewport
  int _currentPage = 0; // Tracks the current page index
  double _opacity = 1.0; // Controls the opacity based on scrolling

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final double offset = widget.scrollController.offset;
    final double opacity = 1.0 - (offset / 200).clamp(0.0, 1.0);
    setState(() {
      _opacity = opacity;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();  // Dispose of the PageController when no longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_opacity <= 0) return const SizedBox.shrink();

    return Opacity(
      opacity: _opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and "View All" button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Headlines',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the CategoryFeedScreen when clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryFeedScreen(
                          category: 'headlines',
                          isHeadlines: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          // Carousel
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.articles.take(5).length,  // Show the first 5 articles
              itemBuilder: (context, index) {
                final article = widget.articles[index]; // Get the current article
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: article.urlToImage != null
                                ? Image.network(
                                    article.urlToImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.newspaper),
                                  ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (article.source != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      article.source!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Stylized Indicators
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.articles.take(5).length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          // Divider for spacing
          const Divider(height: 1),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
} 