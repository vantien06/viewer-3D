import 'package:flutter/widgets.dart';
import 'package:viewer_3d/services/news_service.dart';
import 'package:viewer_3d/models/category_model.dart';
import 'package:viewer_3d/models/news_model.dart';

class NewsProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<News> _newsList = [];
  String? _selectedCategory;
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<News> get newsList => _newsList;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    try {
      _categories = await NewsService.fetchCategories();
      print('Categories fetched: ${_categories.length}');
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchNews({String? category, String? searchQuery}) async {
    _isLoading = true;
    _selectedCategory = category;
    notifyListeners();

    try {
      _newsList = await NewsService.fetchNews(
        category: category,
        searchQuery: searchQuery,
      );
      print('News fetched: ${_newsList.length} articles');
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
