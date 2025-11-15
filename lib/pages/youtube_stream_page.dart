import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class YoutubeStreamPage extends StatefulWidget {
  static const String routeName = '/youtube';

  const YoutubeStreamPage({super.key});

  @override
  State<YoutubeStreamPage> createState() => _YoutubeStreamPageState();
}

class _YoutubeStreamPageState extends State<YoutubeStreamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Scaffold key
  final TextEditingController urlController = TextEditingController();

  String youtubeUrl = '';

  bool isValidYoutubeUrl(String url) {
    final low = url.toLowerCase();
    return (low.contains('youtube.com') || low.contains('youtu.be')) &&
        (low.startsWith('http://') || low.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key to the Scaffold widget
      drawer: const AppDrawer(
        currentRoute: YoutubeStreamPage.routeName,
      ), // AppDrawer for menu
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // No default back button
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
                    onPressed: () => _scaffoldKey.currentState
                        ?.openDrawer(), // Open the drawer on menu button press
                    icon: const Icon(Icons.menu, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  // Giữ nguyên icon link & search để giống UI 3D Viewer
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('YouTube URL: $youtubeUrl'),
                                    ),
                                  );
                                },
                                child: const Text('Insert'),
                              ),
                            ],
                          );
                        },
                      );
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
          const Expanded(child: Center(child: Text('Màn hình Youtube Stream'))),
        ],
      ),
    );
  }
}
