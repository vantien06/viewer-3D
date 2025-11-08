import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

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
      home: const ViewerPage(),
    );
  }
}

class ViewerPage extends StatefulWidget {
  const ViewerPage({super.key});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  final Flutter3DController controller = Flutter3DController();

  bool showInfo = true;

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double viewerWidth = size.width * 0.92;
    double viewerHeight = (size.width < 600) ? size.width : 500;

    final viewer = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: viewerWidth,
        height: viewerHeight,
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Flutter3DViewer(
                src: r'assets\3d\DamagedHelmet.glb',
                controller: controller,
                enableTouch: true,
                progressBarColor: Colors.orange,
                onLoad: (String modelAddress) =>
                    setState(() => isLoading = false),
              ),
            ),
            Positioned(
              // file name
              left: 12,
              top: 12,
              child: AnimatedOpacity(
                opacity: showInfo ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "This is the file name",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: isLoading,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Loading model ...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Viewer'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.people))],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: viewer,
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'toggleInfo',
            onPressed: () => setState(() => showInfo = !showInfo),
            tooltip: "Toggle Info",
            child: Icon(showInfo ? Icons.visibility : Icons.visibility_off),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'resetView',
            onPressed: () {
              controller.resetCameraOrbit();
            },
            tooltip: "Reset View",
            child: Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }
}
