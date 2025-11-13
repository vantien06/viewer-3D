import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class NewsReaderPage extends StatelessWidget {
  static const String routeName = '/news';

  const NewsReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: NewsReaderPage.routeName),
      appBar: AppBar(
        title: const Text('News Reader'),
      ),
      body: const Center(
        child: Text('Màn hình News Reader'),
      ),
    );
  }
}
