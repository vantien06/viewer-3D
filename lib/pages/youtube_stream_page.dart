import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/youtube_video_model.dart';
import '../widgets/app_drawer.dart';
import '../providers/youtube_provider.dart';
import 'youtube_player_page.dart';

class YoutubeStreamPage extends StatefulWidget {
  static const String routeName = '/youtube';

  const YoutubeStreamPage({super.key});

  @override
  State<YoutubeStreamPage> createState() => _YoutubeStreamPageState();
}

class _YoutubeStreamPageState extends State<YoutubeStreamPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final youtubeProvider = Provider.of<YouTubeProvider>(
        context,
        listen: false,
      );
      youtubeProvider.fetchCategories();
      youtubeProvider.searchVideos();
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool isSearching = false;

  String youtubeUrl = '';

  @override
  void dispose() {
    urlController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  bool isValidYoutubeUrl(String url) {
    final low = url.toLowerCase();
    return (low.contains('youtube.com') || low.contains('youtu.be')) &&
        (low.startsWith('http://') || low.startsWith('https://'));
  }

  void _openVideoPlayer(String videoId) {
    final provider = Provider.of<YouTubeProvider>(context, listen: false);
    final video = provider.videos.firstWhere(
      (v) => v.id == videoId,
      orElse: () => provider.videos.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => YouTubePlayerPage(video: video)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(currentRoute: YoutubeStreamPage.routeName),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Youtube Stream',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        searchFocusNode.requestFocus();
                      },
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              isSearching = true;
                            });
                            final provider = Provider.of<YouTubeProvider>(
                              context,
                              listen: false,
                            );
                            provider.searchVideos(searchQuery: value.trim());
                            searchFocusNode.unfocus();
                          }
                        },
                      ),
                    ),
                  ),
                  if (isSearching)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                          searchController.clear();
                        });
                        final provider = Provider.of<YouTubeProvider>(
                          context,
                          listen: false,
                        );
                        provider.searchVideos();
                      },
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  // Link button to add YouTube URL
                  IconButton(
                    onPressed: () async {
                      urlController.text = "";
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Insert YouTube link'),
                            content: TextField(
                              controller: urlController,
                              decoration: const InputDecoration(
                                hintText: 'https://www.youtube.com/watch?v=...',
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final candidate = urlController.text.trim();
                                  if (!isValidYoutubeUrl(candidate)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'URL không hợp lệ. Cần là link YouTube hợp lệ',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    youtubeUrl = candidate;
                                  });
                                  Navigator.of(context).pop();

                                  // Extract video ID and open player
                                  final videoId = _extractVideoId(candidate);
                                  if (videoId != null) {
                                    _openVideoPlayer(videoId);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Could not extract video ID',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Open'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.link),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      searchFocusNode.requestFocus();
                    },
                    child: const Icon(
                      Icons.search,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Categories
          Consumer<YouTubeProvider>(
            builder: (context, provider, child) {
              if (provider.categories.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: provider.selectedCategory == null,
                          onSelected: (_) => provider.searchVideos(),
                        ),
                      );
                    }
                    final category = provider.categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: provider.selectedCategory == category,
                        onSelected: (_) =>
                            provider.searchVideos(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Videos display - vertical list when searching, grid otherwise
          Expanded(
            child: Consumer<YouTubeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.videos.isEmpty) {
                  return const Center(child: Text('No videos available'));
                }

                // Show as vertical list when searching
                if (isSearching) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.videos.length,
                    itemBuilder: (context, index) {
                      final video = provider.videos[index];
                      return _buildVerticalVideoCard(video);
                    },
                  );
                }

                // Show as grid by default
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: provider.videos.length,
                  itemBuilder: (context, index) {
                    final video = provider.videos[index];
                    return InkWell(
                      onTap: () => _openVideoPlayer(video.id),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail with LIVE badge
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    video.thumbnailUrl,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.play_circle_outline,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (video.isLive)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Video info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      video.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    // Channel info with avatar
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage:
                                              video
                                                  .channelThumbnailUrl
                                                  .isNotEmpty
                                              ? NetworkImage(
                                                  video.channelThumbnailUrl,
                                                )
                                              : null,
                                          child:
                                              video.channelThumbnailUrl.isEmpty
                                              ? Text(
                                                  video.channelTitle[0]
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            video.channelTitle,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.remove_red_eye,
                                          size: 12,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatViewCount(video.viewCount),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _extractVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildVerticalVideoCard(YouTubeVideo video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openVideoPlayer(video.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with LIVE badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    video.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.play_circle_outline, size: 60),
                      );
                    },
                  ),
                ),
                if (video.isLive)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Video info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Channel info with avatar
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: video.channelThumbnailUrl.isNotEmpty
                            ? NetworkImage(video.channelThumbnailUrl)
                            : null,
                        child: video.channelThumbnailUrl.isEmpty
                            ? Text(
                                video.channelTitle[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.channelTitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${video.formatViews()} • ${video.formatDate()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
