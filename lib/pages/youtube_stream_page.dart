import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class YoutubeStreamPage extends StatelessWidget {
  static const String routeName = '/youtube';

  const YoutubeStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: YoutubeStreamPage.routeName),
      appBar: AppBar(
        title: const Text('Youtube Stream'),
      ),
      body: const Center(
        child: Text('Màn hình Youtube Stream'),
      ),
    );
  }
}
