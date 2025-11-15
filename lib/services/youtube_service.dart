import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/youtube_video_model.dart';

class YouTubeService {
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String apiKey =
      'AIzaSyDKHYjsSORdkYIHF1Uu-Xdgs9qr-qD28qY'; // Get from https://console.cloud.google.com

  // Predefined categories/search queries
  static List<String> getCategories() {
    return [
      'Gaming',
      'Music',
      'Sports',
      'News',
      'Education',
      'Entertainment',
      'Technology',
      'Live',
    ];
  }

  // Search for videos
  static Future<List<YouTubeVideo>> searchVideos({
    String query = 'live stream',
    String? category,
    int maxResults = 10,
    bool liveOnly = false,
  }) async {
    try {
      final searchQuery = category ?? query;
      final eventType = liveOnly ? '&eventType=live&type=video' : '';

      final url =
          '$baseUrl/search?part=snippet&q=$searchQuery&maxResults=$maxResults$eventType&order=viewCount&key=$apiKey';

      print('🔄 Fetching YouTube videos: $url');
      final response = await http.get(Uri.parse(url));
      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null) {
          final items = data['items'] as List;
          print('Found ${items.length} videos');

          // Extract video IDs
          final videoIds = items
              .where((item) => item['id']['videoId'] != null)
              .map((item) => item['id']['videoId'] as String)
              .toList();

          if (videoIds.isEmpty) {
            return [];
          }

          // Fetch video details including statistics
          return await _getVideoDetails(videoIds, items);
        }
        return [];
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        // Return mock data as fallback
        return _getMockVideos(category ?? query);
      }
    } catch (e) {
      print('Error fetching videos: $e');
      return _getMockVideos(category ?? query);
    }
  }

  // Get video details including statistics (viewCount)
  static Future<List<YouTubeVideo>> _getVideoDetails(
    List<String> videoIds,
    List<dynamic> searchItems,
  ) async {
    try {
      final idsParam = videoIds.join(',');
      final url =
          '$baseUrl/videos?part=snippet,statistics&id=$idsParam&key=$apiKey';

      print('🔄 Fetching video details for view counts');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null) {
          final items = data['items'] as List;

          // Extract unique channel IDs
          final channelIds = items
              .map((item) => item['snippet']['channelId'] as String)
              .toSet()
              .toList();

          // Fetch channel thumbnails
          final channelThumbnails = await _getChannelThumbnails(channelIds);

          // Merge search results with video details and channel thumbnails
          return items.map((item) {
            final snippet = item['snippet'];
            final statistics = item['statistics'];
            final channelId = snippet['channelId'] ?? '';

            return YouTubeVideo(
              id: item['id'],
              title: snippet['title'] ?? 'No Title',
              description: snippet['description'] ?? 'No Description',
              thumbnailUrl:
                  snippet['thumbnails']['high']['url'] ??
                  snippet['thumbnails']['medium']['url'] ??
                  snippet['thumbnails']['default']['url'] ??
                  '',
              channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
              publishedAt: DateTime.parse(
                snippet['publishedAt'] ?? DateTime.now().toIso8601String(),
              ),
              channelId: channelId,
              channelThumbnailUrl: channelThumbnails[channelId] ?? '',
              viewCount: statistics != null
                  ? int.tryParse(statistics['viewCount'] ?? '0') ?? 0
                  : 0,
              isLive: snippet['liveBroadcastContent'] == 'live',
            );
          }).toList();
        }
        return [];
      } else {
        print('Video details API error: ${response.statusCode}');
        // Fallback to basic info from search
        return searchItems.map((item) => YouTubeVideo.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching video details: $e');
      return searchItems.map((item) => YouTubeVideo.fromJson(item)).toList();
    }
  }

  // Get channel thumbnails
  static Future<Map<String, String>> _getChannelThumbnails(
    List<String> channelIds,
  ) async {
    try {
      final idsParam = channelIds.join(',');
      final url = '$baseUrl/channels?part=snippet&id=$idsParam&key=$apiKey';

      print('🔄 Fetching channel thumbnails');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, String> thumbnails = {};

        if (data['items'] != null) {
          for (var item in data['items']) {
            final channelId = item['id'];
            final thumbnailUrl =
                item['snippet']['thumbnails']['default']['url'];
            thumbnails[channelId] = thumbnailUrl;
          }
        }

        return thumbnails;
      }
      return {};
    } catch (e) {
      print('Error fetching channel thumbnails: $e');
      return {};
    }
  }

  // Get live streams
  static Future<List<YouTubeVideo>> getLiveStreams({String? category}) async {
    return searchVideos(
      query: category ?? 'live stream',
      category: category,
      liveOnly: true,
    );
  }

  // Mock data as fallback
  static List<YouTubeVideo> _getMockVideos(String category) {
    return [
      YouTubeVideo(
        id: 'mock1',
        title: 'Live: $category Gaming Stream',
        description: 'Watch the most exciting $category gameplay live!',
        thumbnailUrl: 'https://picsum.photos/320/180?random=1',
        channelTitle: 'ProGamer Channel',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
        channelId: 'channel1',
        viewCount: 12500,
        isLive: true,
      ),
      YouTubeVideo(
        id: 'mock2',
        title: '$category Music Concert 2024',
        description: 'Amazing live music performance featuring top artists.',
        thumbnailUrl: 'https://picsum.photos/320/180?random=2',
        channelTitle: 'Music Live TV',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        channelId: 'channel2',
        viewCount: 45000,
        isLive: false,
      ),
      YouTubeVideo(
        id: 'mock3',
        title: 'Breaking: $category News Live Stream',
        description: 'Latest updates and breaking news coverage.',
        thumbnailUrl: 'https://picsum.photos/320/180?random=3',
        channelTitle: 'News Network',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        channelId: 'channel3',
        viewCount: 8900,
        isLive: true,
      ),
    ];
  }
}
