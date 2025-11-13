import 'package:flutter/material.dart';
import '../pages/viewer_page.dart';
import '../pages/youtube_stream_page.dart';
import '../pages/news_reader_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _go(BuildContext context, String routeName) {
    Navigator.pop(context); // đóng Drawer
    if (routeName == currentRoute) return; // đang ở màn đó rồi

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.view_in_ar),
              title: const Text('3D Viewer'),
              selected: currentRoute == ViewerPage.routeName,
              onTap: () => _go(context, ViewerPage.routeName),
            ),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('Youtube Stream'),
              selected: currentRoute == YoutubeStreamPage.routeName,
              onTap: () => _go(context, YoutubeStreamPage.routeName),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('News Reader'),
              selected: currentRoute == NewsReaderPage.routeName,
              onTap: () => _go(context, NewsReaderPage.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
