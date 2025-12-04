import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../providers/news_provider.dart';
import '../providers/youtube_provider.dart';
import 'about_us_page.dart';
import 'news_detail_page.dart';
import 'youtube_player_page.dart';

class MainPage extends StatefulWidget {
  static const String routeName = '/main';

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; // Mặc định là 3D Viewer (giữa)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _NewsReaderContent(key: const PageStorageKey('news')),
          _ViewerContent(key: const PageStorageKey('viewer')),
          _YoutubeStreamContent(key: const PageStorageKey('youtube')),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.article_outlined,
                selectedIcon: Icons.article,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.view_in_ar_outlined,
                selectedIcon: Icons.view_in_ar,
                isCenter: true,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.play_circle_outline,
                selectedIcon: Icons.play_circle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    bool isCenter = false,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            size: isCenter ? 32 : 26,
            color: isSelected
                ? const Color(0xFF26C6DA)
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 6),
          // Indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF26C6DA)
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== NEWS READER CONTENT ====================
class _NewsReaderContent extends StatefulWidget {
  const _NewsReaderContent({super.key});

  @override
  State<_NewsReaderContent> createState() => _NewsReaderContentState();
}

class _NewsReaderContentState extends State<_NewsReaderContent> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool isSearching = false;
  String newsUrl = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.fetchCategories();
      newsProvider.fetchNews();
    });
  }

  @override
  void dispose() {
    urlController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  bool isValidNewsUrl(String url) {
    final low = url.toLowerCase();
    return low.startsWith('http://') || low.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    'News Reader',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AboutUsPage.routeName);
                    },
                    child: const Text(
                      'About us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                const SizedBox(width: 16),
                const Icon(Icons.search, size: 22, color: Colors.black87),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() => isSearching = true);
                        Provider.of<NewsProvider>(context, listen: false)
                            .fetchNews(searchQuery: value.trim());
                        searchFocusNode.unfocus();
                      }
                    },
                  ),
                ),
                if (isSearching)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = false;
                        searchController.clear();
                      });
                      Provider.of<NewsProvider>(context, listen: false).fetchNews();
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                IconButton(
                  onPressed: () => _showInsertUrlDialog(),
                  icon: const Icon(Icons.link),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Categories
        Consumer<NewsProvider>(
          builder: (context, newsProvider, child) {
            if (newsProvider.categories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newsProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: newsProvider.selectedCategory == null,
                        onSelected: (_) => newsProvider.fetchNews(),
                      ),
                    );
                  }
                  final category = newsProvider.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: newsProvider.selectedCategory == category.name,
                      onSelected: (_) => newsProvider.fetchNews(category: category.name),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // News list
        Expanded(
          child: Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              if (newsProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (newsProvider.newsList.isEmpty) {
                return const Center(child: Text('No news available'));
              }
              return _buildNewsList(newsProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsList(NewsProvider newsProvider) {
    if (isSearching || newsProvider.selectedCategory != null) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsProvider.newsList.length,
        itemBuilder: (context, index) => _buildNewsCard(newsProvider.newsList[index]),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Latest news', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFeaturedCard(newsProvider.newsList[0]),
          ),
          const SizedBox(height: 20),
          if (newsProvider.newsList.length > 1) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Other news', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newsProvider.newsList.length - 1,
                itemBuilder: (context, index) => _buildSmallCard(newsProvider.newsList[index + 1]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewsCard(news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: news.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(news.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
              )
            : null,
        title: Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(news.category),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailPage(news: news))),
      ),
    );
  }

  Widget _buildFeaturedCard(news) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailPage(news: news))),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${news.publishedAt.year}-${news.publishedAt.month}-${news.publishedAt.day} ${news.publishedAt.hour}:${news.publishedAt.minute.toString().padLeft(2, '0')} PM ET',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 8),
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(news.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(news) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailPage(news: news))),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(news.imageUrl, height: 100, width: 140, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(news.category, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _showInsertUrlDialog() async {
    urlController.text = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert News link'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com/news'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final candidate = urlController.text.trim();
              if (!isValidNewsUrl(candidate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL không hợp lệ')),
                );
                return;
              }
              setState(() => newsUrl = candidate);
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }
}

// ==================== 3D VIEWER CONTENT ====================
class _ViewerContent extends StatefulWidget {
  const _ViewerContent({super.key});

  @override
  State<_ViewerContent> createState() => _ViewerContentState();
}

class _ViewerContentState extends State<_ViewerContent> {
  final Flutter3DController controller = Flutter3DController();
  final TextEditingController urlController = TextEditingController();

  String modelUrl = 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
  String modelName = 'Astronaut.glb';
  bool showInfo = true;
  bool isLoading = true;
  bool isRotating = false;

  bool isValidUrl(String url) {
    final low = url.toLowerCase();
    return (low.startsWith('http://') || low.startsWith('https://')) && low.endsWith('glb');
  }

  String extractModelName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
    } catch (e) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double viewerHeight = (size.width < 600) ? size.width * 0.85 : 400;

    return Column(
      children: [
        // AppBar
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    '3D Viewer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AboutUsPage.routeName);
                    },
                    child: const Text(
                      'About us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                const SizedBox(width: 16),
                const Icon(Icons.search, size: 22, color: Colors.black87),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Search', style: TextStyle(fontSize: 16, color: Colors.black45)),
                ),
                IconButton(
                  onPressed: () => _showInsertUrlDialog(),
                  icon: const Icon(Icons.link),
                ),
              ],
            ),
          ),
        ),
        // 3D Viewer
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    height: viewerHeight,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Flutter3DViewer(
                            src: modelUrl,
                            controller: controller,
                            enableTouch: true,
                            progressBarColor: Colors.orange,
                            onLoad: (String modelAddress) {
                              setState(() {
                                isLoading = false;
                                modelName = extractModelName(modelUrl);
                              });
                            },
                            onError: (String error) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Can not load model: $error')),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: AnimatedOpacity(
                            opacity: showInfo ? 1 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Text(modelName, style: const TextStyle(color: Colors.white70)),
                          ),
                        ),
                        if (isLoading)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                  SizedBox(width: 12),
                                  Text("Loading model ...", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Floating buttons
                Positioned(
                  right: 8,
                  top: 50,
                  child: Column(
                    children: [
                      _buildFloatingButton(
                        icon: showInfo ? Icons.visibility : Icons.visibility_off,
                        onPressed: () => setState(() => showInfo = !showInfo),
                      ),
                      const SizedBox(height: 12),
                      _buildFloatingButton(
                        icon: Icons.center_focus_strong,
                        onPressed: () => controller.resetCameraOrbit(),
                      ),
                      const SizedBox(height: 12),
                      _buildFloatingButton(
                        icon: isRotating ? Icons.pause : Icons.play_arrow,
                        onPressed: () {
                          setState(() {
                            if (isRotating) {
                              controller.pauseRotation();
                            } else {
                              controller.startRotation(rotationSpeed: 90);
                            }
                            isRotating = !isRotating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF26C6DA)),
        onPressed: onPressed,
      ),
    );
  }

  void _showInsertUrlDialog() async {
    urlController.text = "https://modelviewer.dev/shared-assets/models/Horse.glb";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert model link'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com/model.glb'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final candidate = urlController.text.trim();
              if (!isValidUrl(candidate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL không hợp lệ. Cần bắt đầu bằng http/https và kết thúc .glb')),
                );
                return;
              }
              setState(() {
                if (modelUrl != candidate) isLoading = true;
                modelUrl = candidate;
                modelName = extractModelName(candidate);
              });
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }
}

// ==================== YOUTUBE STREAM CONTENT ====================
class _YoutubeStreamContent extends StatefulWidget {
  const _YoutubeStreamContent({super.key});

  @override
  State<_YoutubeStreamContent> createState() => _YoutubeStreamContentState();
}

class _YoutubeStreamContentState extends State<_YoutubeStreamContent> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final youtubeProvider = Provider.of<YouTubeProvider>(context, listen: false);
      youtubeProvider.fetchCategories();
      youtubeProvider.searchVideos();
    });
  }

  @override
  void dispose() {
    urlController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    'Youtube Stream',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AboutUsPage.routeName);
                    },
                    child: const Text(
                      'About us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                const SizedBox(width: 16),
                const Icon(Icons.search, size: 22, color: Colors.black87),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() => isSearching = true);
                        Provider.of<YouTubeProvider>(context, listen: false)
                            .searchVideos(searchQuery: value.trim());
                        searchFocusNode.unfocus();
                      }
                    },
                  ),
                ),
                if (isSearching)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = false;
                        searchController.clear();
                      });
                      Provider.of<YouTubeProvider>(context, listen: false).searchVideos();
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                IconButton(
                  onPressed: () => _showInsertUrlDialog(),
                  icon: const Icon(Icons.link),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Categories
        Consumer<YouTubeProvider>(
          builder: (context, youtubeProvider, child) {
            if (youtubeProvider.categories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: youtubeProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: youtubeProvider.selectedCategory == null,
                        onSelected: (_) => youtubeProvider.searchVideos(),
                      ),
                    );
                  }
                  final category = youtubeProvider.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: youtubeProvider.selectedCategory == category,
                      onSelected: (_) => youtubeProvider.searchVideos(category: category),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Video grid
        Expanded(
          child: Consumer<YouTubeProvider>(
            builder: (context, youtubeProvider, child) {
              if (youtubeProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (youtubeProvider.videos.isEmpty) {
                return const Center(child: Text('No videos available'));
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: youtubeProvider.videos.length,
                itemBuilder: (context, index) {
                  final video = youtubeProvider.videos[index];
                  return _buildVideoCard(video);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => YouTubePlayerPage(video: video)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(video.channelThumbnailUrl),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            video.channelTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${video.viewCount} lượt xem',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
  }

  void _showInsertUrlDialog() async {
    urlController.text = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert YouTube link'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://youtube.com/watch?v=...'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }
}

