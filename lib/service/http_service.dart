import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class HttpService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = '31927856f41340c38a6b0a6db4761b67';

  // Check if there is an active internet connection by attempting to resolve Google's domain
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty; // Return true if lookup succeeds
    } on SocketException catch (_) {
      return false;
    }
  }

  // Fetch top headlines from the News API with a fixed country and limit
  Future<Map<String, dynamic>> getTopHeadlines({int pageSize = 100}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('$_baseUrl/top-headlines?country=us&pageSize=$pageSize&apiKey=$_apiKey&sortBy=publishedAt'),
      headers: {
        'Cache-Control': 'no-cache',
        'If-None-Match': timestamp.toString(),
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load top headlines');
    }
  }

  // Fetch all news articles with optional sorting and query parameters
  Future<Map<String, dynamic>> getAllNews({String? sortBy, String? query}) async {
    // Get news using the category endpoint for standard categories
    if (query != null) {
      try {
        // Convert category name to API expected format
        String categoryQuery = query.toLowerCase().replaceAll(' & ', '-');
        switch (categoryQuery) {
          case 'business':
          case 'entertainment':
          case 'health':
          case 'science':
          case 'sports':
          case 'technology':
            // Use top-headlines with category parameter for standard categories
            final response = await http.get(
              Uri.parse('$_baseUrl/top-headlines?country=us&category=$categoryQuery&pageSize=100&apiKey=$_apiKey'),
            );
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if ((data['articles'] as List).isNotEmpty) {
                return data; // Return the data if articles are available
              }
            }
        }
      } catch (e) {
        print('Category endpoint failed, falling back to search: $e'); // Log the error and fallback
      }
    }

    // Fall back to everything endpoint with enhanced search for custom categories
    String finalQuery = query ?? 'news';
    
    // Category query logic
    switch (query?.toLowerCase()) {
      case 'politics':
        finalQuery = '(politics OR government OR election OR "political news") -entertainment -sports';
        break;
      case 'current events':
        finalQuery = '(breaking news OR current events OR "latest news") AND (local OR national OR community)';
        break;
      case 'business':
        finalQuery = '(business OR economy OR finance OR market OR trade) -entertainment -sports';
        break;
      case 'technology':
        finalQuery = '(technology OR tech OR innovation OR "artificial intelligence" OR digital) -entertainment';
        break;
      case 'sports':
        finalQuery = '(sports OR olympics OR football OR basketball OR baseball OR "premier league") -politics';
        break;
      case 'entertainment':
        finalQuery = '(entertainment OR movie OR music OR celebrity OR television) -politics -business';
        break;
      case 'health':
        finalQuery = '(health OR medical OR healthcare OR wellness OR "public health") -entertainment';
        break;
      case 'science':
        finalQuery = '(science OR research OR discovery OR space OR "scientific breakthrough") -entertainment';
        break;
      default:
        finalQuery = query ?? 'news';
    }

    final queryParams = {
      'apiKey': _apiKey,
      'language': 'en',
      'sortBy': sortBy ?? 'publishedAt',
      'q': finalQuery,
      'pageSize': '100',
    };

    final response = await http.get(
      Uri.parse('$_baseUrl/everything').replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load news');
    }
  }

  // Search for news articles with advanced filtering and pagination
  Future<Map<String, dynamic>> searchNews({
    required String query, // The query string for searching
    String? sortBy, // Optional sorting method
    String? language = 'en',
    int page = 1,
    String searchIn = 'title,description,content', // Fields to search in
  }) async {
    // Enhanced search query based on topic
    String enhancedQuery = query;
    
    // Convert query to lowercase for comparison
    switch (query.toLowerCase()) {
      case 'technology':
        enhancedQuery = '(technology OR tech OR innovation OR "artificial intelligence" OR digital) -entertainment';
        break;
      case 'climate':
        enhancedQuery = '(climate OR "climate change" OR environment OR "global warming" OR sustainability)';
        break;
      case 'business':
        enhancedQuery = '(business OR economy OR finance OR market OR trade) -entertainment -sports';
        break;
      case 'sports':
        enhancedQuery = '(sports OR olympics OR football OR basketball OR baseball OR "premier league") -politics';
        break;
      case 'health':
        enhancedQuery = '(health OR medical OR healthcare OR wellness OR "public health") -entertainment';
        break;
      case 'politics':
        enhancedQuery = '(politics OR government OR election OR "political news") -entertainment -sports';
        break;
    }

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/everything?q=$enhancedQuery'
        '${sortBy != null ? '&sortBy=$sortBy' : ''}'
        '&language=$language'
        '&page=$page'
        '&searchIn=$searchIn'
        '&apiKey=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search news');
    }
  }

  // Fetch news articles by category using the top-headlines endpoint
  Future<Map<String, dynamic>> getNewsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/top-headlines?apiKey=$_apiKey&category=$category&country=us'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load category news');
    }
  }
}
