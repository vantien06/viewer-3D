import 'package:flutter/widgets.dart';
import '../services/youtube_service.dart';
import '../models/youtube_video_model.dart';

class YouTubeProvider with ChangeNotifier {
  List<String> _categories = [];
  List<YouTubeVideo> _videos = [];
  String? _selectedCategory;
  bool _isLoading = false;
  bool _showLiveOnly = false;

  List<String> get categories => _categories;
  List<YouTubeVideo> get videos => _videos;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get showLiveOnly => _showLiveOnly;

  void fetchCategories() {
    _categories = YouTubeService.getCategories();
    print('Categories loaded: ${_categories.length}');
    notifyListeners();
  }

  Future<void> searchVideos({
    String? category,
    bool? liveOnly,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _selectedCategory = category;
    if (liveOnly != null) _showLiveOnly = liveOnly;
    notifyListeners();

    try {
      if (_showLiveOnly) {
        _videos = await YouTubeService.getLiveStreams(category: category);
      } else {
        _videos = await YouTubeService.searchVideos(
          query: searchQuery ?? category ?? 'trending',
          category: category,
        );
      }
      print('Videos loaded: ${_videos.length}');
    } catch (e) {
      print('Error loading videos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleLiveOnly() {
    _showLiveOnly = !_showLiveOnly;
    searchVideos(category: _selectedCategory, liveOnly: _showLiveOnly);
  }
}
