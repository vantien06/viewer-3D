import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../widgets/app_drawer.dart';

class ViewerPage extends StatefulWidget {
  static const String routeName = '/viewer';

  const ViewerPage({super.key});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  final Flutter3DController controller = Flutter3DController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String modelUrl =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
  String modelName = 'Astronaut.glb';

  final TextEditingController urlController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool isValidUrl(String url) {
    final low = url.toLowerCase();
    return ((low.startsWith('http://') || low.startsWith('https://')) &&
        (low.endsWith('glb')));
  }

  String extractModelName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
    } catch (e) {
      return url;
    }
  }

  bool showInfo = true;
  bool isLoading = true;
  bool isRotating = false;

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
                child: Text(modelName),
              ),
            ),
            Center(
              child: Visibility(
                visible: isLoading,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
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
      key: _scaffoldKey,
      drawer: const AppDrawer(currentRoute: ViewerPage.routeName),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          '3D Viewer',
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
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      urlController.text =
                          "https://modelviewer.dev/shared-assets/models/Horse.glb";
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Insert model link'),
                            content: TextField(
                              controller: urlController,
                              decoration: const InputDecoration(
                                hintText: 'https://example.com/model.glb',
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final candidate =
                                      urlController.text.trim();
                                  if (!isValidUrl(candidate)) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'URL không hợp lệ. Cần bắt đầu bằng http/https và kết thúc .glb',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    if (modelUrl != candidate) {
                                      isLoading = true;
                                    }
                                    modelUrl = candidate;
                                    modelName = extractModelName(candidate);
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Load'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: const Alignment(0, -0.8),
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
        ],
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
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'rotate',
            onPressed: () => setState(() {
              if (isRotating) {
                controller.pauseRotation();
              } else {
                controller.startRotation(rotationSpeed: 90);
              }
              isRotating = !isRotating;
            }),
            tooltip: "Rotate Model",
            child: Icon(isRotating ? Icons.pause : Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
