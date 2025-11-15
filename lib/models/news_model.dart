class News {
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String category;
  final DateTime publishedAt;
  final String source;

  News({
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.publishedAt,
    required this.source,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'General',
      publishedAt: DateTime.parse(
        json['publishedAt'] ?? DateTime.now().toIso8601String(),
      ),
      source: json['source'] ?? 'Unknown Source',
    );
  }
}
