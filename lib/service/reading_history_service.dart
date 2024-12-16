import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/article.dart';

/* Manages the reading history state, including adding, removing, and clearing articles from history.
Data is persisted using SharedPreferences for storage between app launches.*/
class ReadingHistoryState extends ChangeNotifier {
  List<Article> _readArticles = []; // list to store the articles the user has read
  static const String _historyKey = 'reading_history';
  static const int _maxHistoryItems = 100; // Limit history items
  late SharedPreferences _prefs;

  ReadingHistoryState() {
    _initPrefs();
  }

  // Initialize the SharedPreferences instance and loads saved reading history
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadHistory(); // Load any existing reading history from SharedPreferences
  }

  // Load the reading history from SharedPreferences and convert it into a list of Article objects.
  void _loadHistory() {
    final String? historyJson = _prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      _readArticles = historyList
          .map((item) => Article.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  // Save the current reading history to SharedPreferences in JSON format
  Future<void> _saveHistory() async {
    final String historyJson = json.encode(
      _readArticles.map((article) => article.toJson()).toList(),
    );
    await _prefs.setString(_historyKey, historyJson);
  }

  // Getter to retrieve the list of read articles
  List<Article> get readArticles => _readArticles;

  // Add an article to the reading history, ensuring no duplicates and maintaining the max limit
  Future<void> addToHistory(Article article) async {
    // Remove if already exists to avoid duplicates
    _readArticles.removeWhere((a) => a.url == article.url);
    
    // Add to the beginning of the list
    _readArticles.insert(0, article);
    
    // Limit the history size
    if (_readArticles.length > _maxHistoryItems) {
      _readArticles = _readArticles.sublist(0, _maxHistoryItems);
    }
    
    await _saveHistory(); // Save the updated history to SharedPreferences
    notifyListeners();
  }

  // Remove an article from the reading history
  Future<void> removeFromHistory(Article article) async {
    _readArticles.removeWhere((a) => a.url == article.url);
    await _saveHistory();
    notifyListeners();
  }

  // Clear the entire reading history from memory and SharedPreferences
  Future<void> clearHistory() async {
    _readArticles.clear();
    await _prefs.remove(_historyKey);
    notifyListeners();
  }
} 