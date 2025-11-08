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
  final Flutter3DController _controller = Flutter3DController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Viewer')),
      body: Center(
        child: Flutter3DViewer(
          controller: _controller,
          // Dùng model GLB mẫu có sẵn online
          // src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
          src: 'assets/3d/DamagedHelmet.glb',
          enableTouch: true,
        ),
      ),
    );
  }
}
