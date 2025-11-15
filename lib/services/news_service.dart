import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:viewer_3d/models/news_model.dart';
import 'package:viewer_3d/models/category_model.dart';

class NewsService {
  // Using NewsAPI (requires free API key from https://newsapi.org)
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey = 'f18eb5c7bf8148ff80e51bf177d83383';

  // Alternative: GNews API
  // static const String baseUrl = 'https://gnews.io/api/v4';
  // static const String apiKey = 'YOUR_GNEWS_KEY';

  static Future<List<Category>> fetchCategories() async {
    // Return predefined categories
    return [
      Category(name: 'General', icon: '📰'),
      Category(name: 'Business', icon: '💼'),
      Category(name: 'Technology', icon: '💻'),
      Category(name: 'Sports', icon: '⚽'),
      Category(name: 'Entertainment', icon: '🎬'),
      Category(name: 'Health', icon: '🏥'),
      Category(name: 'Science', icon: '🔬'),
    ];
  }

  static Future<List<News>> fetchNews({
    String? category,
    String? searchQuery,
  }) async {
    try {
      // Using NewsAPI
      final String url;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Use everything endpoint for search
        url = '$baseUrl/everything?q=$searchQuery&pageSize=20&apiKey=$apiKey';
      } else {
        // Use top-headlines endpoint for category
        final topic = category?.toLowerCase() ?? 'general';
        url =
            '$baseUrl/top-headlines?category=$topic&country=us&pageSize=10&apiKey=$apiKey';
      }

      print('Fetching news from: $url');
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: ${data.keys}');

        if (data['articles'] != null) {
          final articles = data['articles'] as List;
          print('Found ${articles.length} articles');

          return List<News>.from(
            articles.map(
              (article) => News(
                title: article['title'] ?? 'No Title',
                description: article['description'] ?? 'No Description',
                content: article['content'] ?? article['description'] ?? '',
                imageUrl: article['urlToImage'] ?? '',
                category: category ?? 'General',
                publishedAt: DateTime.parse(
                  article['publishedAt'] ?? DateTime.now().toIso8601String(),
                ),
                source: article['source']?['name'] ?? 'Unknown Source',
              ),
            ),
          );
        }
        print('No articles in response');
        return [];
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      // Return mock data as fallback
      print('Using mock data as fallback');
      return _getMockNews(category);
    }
  }

  // Fallback mock data if API fails
  static List<News> _getMockNews(String? category) {
    return [
      News(
        title: 'Breaking: Flutter 4.0 Released',
        description:
            'Google announces major update to Flutter framework with new features and improvements.',
        content:
            'Flutter 4.0 brings significant performance improvements and new widgets...',
        imageUrl: 'https://picsum.photos/400/200',
        category: category ?? 'Technology',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'Tech News',
      ),
      News(
        title: 'Global Markets Rise Amid Positive Economic Data',
        description:
            'Stock markets worldwide see gains as economic indicators show strong growth.',
        content:
            'Markets responded positively to the latest economic reports...',
        imageUrl: 'https://picsum.photos/400/201',
        category: category ?? 'Business',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        source: 'Financial Times',
      ),
      News(
        title: 'New Scientific Discovery in Space Exploration',
        description:
            'Scientists discover potentially habitable exoplanet in nearby star system.',
        content: 'A team of astronomers has made a groundbreaking discovery...',
        imageUrl: 'https://picsum.photos/400/202',
        category: category ?? 'Science',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: 'Science Daily',
      ),
    ];
  }
}
