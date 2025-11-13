import 'package:flutter/material.dart';
import 'pages/viewer_page.dart';
import 'pages/youtube_stream_page.dart';
import 'pages/news_reader_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Viewer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF), // Xanh biển
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF), // Xanh biển
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,

      // màn hình mở đầu
      initialRoute: ViewerPage.routeName,

      routes: {
        ViewerPage.routeName: (context) => const ViewerPage(),
        YoutubeStreamPage.routeName: (context) => const YoutubeStreamPage(),
        NewsReaderPage.routeName: (context) => const NewsReaderPage(),
      },
    );
  }
}
