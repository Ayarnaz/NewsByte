import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/article.dart';


/* Manages the bookmark state for the application, including persistence
and state synchronization with listeners.*/
class BookmarkState extends ChangeNotifier {
  Set<String> _bookmarkedUrls = {}; // A set to track bookmarked article URLs for quick lookups.
  List<Article> _bookmarkedArticles = []; // List of bookmarked articles with full details.
  static const String _bookmarksKey = 'bookmarked_articles';
  late SharedPreferences _prefs; // SharedPreferences instance used for persistent storage.
  bool _initialized = false;

  BookmarkState() {
    _initPrefs();
  }

  // Initialize the SharedPreferences instance and loads bookmarks from storage
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBookmarks();
    _initialized = true;
    notifyListeners();
  }

  // Load bookmarks from SharedPreferences and synchronizes in-memory state
  void _loadBookmarks() {
    final String? bookmarksJson = _prefs.getString(_bookmarksKey);
    if (bookmarksJson != null) {
      final List<dynamic> bookmarksList = json.decode(bookmarksJson);
      _bookmarkedArticles = bookmarksList
          .map((item) => Article.fromJson(item))
          .toList();
      _bookmarkedUrls = _bookmarkedArticles
          .map((article) => article.url ?? '')
          .where((url) => url.isNotEmpty)
          .toSet();
      notifyListeners();
    }
  }
  // Save the current bookmarks to SharedPreferences as a JSON string.
  Future<void> _saveBookmarks() async {
    final String bookmarksJson = json.encode(
      _bookmarkedArticles.map((article) => article.toJson()).toList(),
    );
    await _prefs.setString(_bookmarksKey, bookmarksJson);
  }

  List<Article> get bookmarkedArticles => _bookmarkedArticles; // Get the list of bookmarked articles
  bool isBookmarked(String url) => _bookmarkedUrls.contains(url); // Checks if a given URL is bookmarked

  // Add an article to the bookmarks if it is not already bookmarked
  Future<void> addBookmark(Article article) async {
    if (article.url != null && !_bookmarkedUrls.contains(article.url)) {
      _bookmarkedUrls.add(article.url!);
      _bookmarkedArticles.add(article);
      await _saveBookmarks();
      notifyListeners();
    }
  }

  // Remove an article from the bookmarks if it exists
  Future<void> removeBookmark(Article article) async {
    if (article.url != null) {
      _bookmarkedUrls.remove(article.url);
      _bookmarkedArticles.removeWhere((a) => a.url == article.url);
      await _saveBookmarks();
      notifyListeners();
    }
  }

  /* Toggle the bookmark state of an article (adds if not bookmarked,
   removes if already bookmarked).*/
  Future<void> toggleBookmark(Article article) async {
    if (isBookmarked(article.url ?? '')) {
      await removeBookmark(article);
    } else {
      await addBookmark(article);
    }
  }

  /* Clear all bookmarks from both memory and persistent storage (Removed function)
  Future<void> clearBookmarks() async {
    _bookmarkedUrls.clear();
    _bookmarkedArticles.clear();
    await _prefs.remove(_bookmarksKey);
    notifyListeners();
  }*/

  bool get isInitialized => _initialized;
} 