class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;
  final String channelId;
  final String channelThumbnailUrl;
  final int viewCount;
  final bool isLive;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
    required this.channelId,
    this.channelThumbnailUrl = '',
    this.viewCount = 0,
    this.isLive = false,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final statistics = json['statistics'];

    return YouTubeVideo(
      id: json['id']['videoId'] ?? json['id'] ?? '',
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
      channelId: snippet['channelId'] ?? '',
      channelThumbnailUrl: '',
      viewCount: statistics != null
          ? int.tryParse(statistics['viewCount'] ?? '0') ?? 0
          : 0,
      isLive: snippet['liveBroadcastContent'] == 'live',
    );
  }

  String formatViews() {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewCount views';
  }

  String formatDate() {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }
}
