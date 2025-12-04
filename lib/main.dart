import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/viewer_page.dart';
import 'pages/youtube_stream_page.dart';
import 'pages/news_reader_page.dart';
import 'pages/about_us_page.dart';
import 'pages/splash_page.dart';
import 'pages/main_page.dart';
import 'pages/ai_scanner_page.dart';
import 'providers/news_provider.dart';
import 'providers/youtube_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => YouTubeProvider()),
      ],
      child: MaterialApp(
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
        initialRoute: SplashPage.routeName,

        routes: {
          SplashPage.routeName: (context) => const SplashPage(),
          MainPage.routeName: (context) => const MainPage(),
          ViewerPage.routeName: (context) => const ViewerPage(),
          YoutubeStreamPage.routeName: (context) => const YoutubeStreamPage(),
          NewsReaderPage.routeName: (context) => const NewsReaderPage(),
          AboutUsPage.routeName: (context) => const AboutUsPage(),
          AIScannerPage.routeName: (context) => const AIScannerPage(),
        },
        builder: (context, child) {
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const Positioned.fill(
                child: IgnorePointer(
                  child: WatermarkOverlay(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WatermarkOverlay extends StatelessWidget {
  const WatermarkOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final watermarks = <Widget>[];
        const spacingY = 100.0;
        const spacingX = 300.0;
        
        for (double y = 30; y < constraints.maxHeight; y += spacingY) {
          for (double x = -100; x < constraints.maxWidth + 100; x += spacingX) {
            watermarks.add(
              Positioned(
                left: x + (y ~/ spacingY % 2 == 0 ? 0 : spacingX / 2),
                top: y,
                child: Transform.rotate(
                  angle: -0.35,
                  child: Text(
                    'HCMUT Demo Application',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.08),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            );
          }
        }
        
        return Stack(children: watermarks);
      },
    );
  }
}
