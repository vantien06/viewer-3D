import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/youtube_video_model.dart';
import '../providers/youtube_provider.dart';
import '../widgets/app_drawer.dart';

class YouTubePlayerPage extends StatefulWidget {
  static const String routeName = '/youtube-player';
  final YouTubeVideo video;

  const YouTubePlayerPage({super.key, required this.video});

  @override
  State<YouTubePlayerPage> createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
  late YoutubePlayerController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _urlController = TextEditingController();
  String youtubeUrl = '';

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool _isValidYoutubeUrl(String url) {
    final low = url.toLowerCase();
    return (low.contains('youtube.com') || low.contains('youtu.be')) &&
        (low.startsWith('http://') || low.startsWith('https://'));
  }

  String? _extractVideoId(String url) {
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

  void _openVideoPlayer(String videoId) {
    final provider = Provider.of<YouTubeProvider>(context, listen: false);
    final video = provider.videos.firstWhere(
      (v) => v.id == videoId,
      orElse: () => provider.videos.first,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => YouTubePlayerPage(video: video)),
    );
  }

  void _showLinkDialog(BuildContext context) async {
    _urlController.text = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insert YouTube link'),
          content: TextField(
            controller: _urlController,
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
                final candidate = _urlController.text.trim();
                if (!_isValidYoutubeUrl(candidate)) {
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
                    const SnackBar(content: Text('Could not extract video ID')),
                  );
                }
              },
              child: const Text('Open'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          print('Player is ready.');
        },
      ),
      builder: (context, player) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: YouTubePlayerPage.routeName),
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'YouTube Player',
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
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Search",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Show link input dialog
                          _showLinkDialog(context);
                        },
                        icon: const Icon(Icons.link),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.search, size: 22, color: Colors.black),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Categories bar
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
                              onSelected: (_) {
                                provider.searchVideos();
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }
                        final category = provider.categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: provider.selectedCategory == category,
                            onSelected: (_) {
                              provider.searchVideos(category: category);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // YouTube Player
              player,
              // Video info (closer to video)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Views and date
                        Text(
                          '${widget.video.formatViews()} • ${widget.video.formatDate()}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Channel info with avatar
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  widget.video.channelThumbnailUrl.isNotEmpty
                                  ? NetworkImage(
                                      widget.video.channelThumbnailUrl,
                                    )
                                  : null,
                              child: widget.video.channelThumbnailUrl.isEmpty
                                  ? Text(
                                      widget.video.channelTitle[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.video.channelTitle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          'Description',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.video.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Videos'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
