import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_recognition_service.dart';
import '../widgets/app_drawer.dart';
import 'viewer_page.dart';

class AIScannerPage extends StatefulWidget {
  static const String routeName = '/ai-scanner';

  const AIScannerPage({super.key});

  @override
  State<AIScannerPage> createState() => _AIScannerPageState();
}

class _AIScannerPageState extends State<AIScannerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AIRecognitionService _aiService = AIRecognitionService();
  final ImagePicker _imagePicker = ImagePicker();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isFlashOn = false;
  File? _capturedImage;
  ScanResult? _scanResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _aiService.initialize();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      setState(() {
        _capturedImage = imageFile;
      });

      final result = await _aiService.scanAndGetModel(imageFile);

      setState(() {
        _scanResult = result;
        _isScanning = false;
      });

      if (result.hasMatch) {
        _showResultDialog(result);
      } else {
        _showNoMatchDialog(result);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi quét: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        setState(() {
          _isScanning = false;
        });
        return;
      }

      final File imageFile = File(image.path);

      setState(() {
        _capturedImage = imageFile;
      });

      final result = await _aiService.scanAndGetModel(imageFile);

      setState(() {
        _scanResult = result;
        _isScanning = false;
      });

      if (result.hasMatch) {
        _showResultDialog(result);
      } else {
        _showNoMatchDialog(result);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi quét: $e')),
        );
      }
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _showResultDialog(ScanResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Đã nhận dạng!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phát hiện: ${result.matchedModel!.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Các vật thể được nhận dạng:'),
            const SizedBox(height: 8),
            ...result.recognizedObjects.take(5).map((obj) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.label, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(obj.label)),
                      Text(
                        obj.confidencePercent,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Quét lại'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToViewer(result.matchedModel!);
            },
            icon: const Icon(Icons.view_in_ar),
            label: const Text('Xem 3D'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26C6DA),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showNoMatchDialog(ScanResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('Không tìm thấy'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Không tìm thấy model 3D phù hợp.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (result.recognizedObjects.isNotEmpty) ...[
              const Text('Các vật thể được nhận dạng:'),
              const SizedBox(height: 8),
              ...result.recognizedObjects.take(5).map((obj) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.label, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(obj.label)),
                        Text(
                          obj.confidencePercent,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )),
            ] else
              const Text('Không nhận dạng được vật thể nào.'),
            const SizedBox(height: 12),
            const Text(
              'Hỗ trợ: mèo, chó, ngựa, người',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Quét lại'),
          ),
        ],
      ),
    );
  }

  void _navigateToViewer(Model3DInfo model) {
    Navigator.pushReplacementNamed(
      context,
      ViewerPage.routeName,
      arguments: model.modelUrl,
    );
  }

  void _resetScan() {
    setState(() {
      _capturedImage = null;
      _scanResult = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(currentRoute: AIScannerPage.routeName),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'AI Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isCameraInitialized)
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Camera Preview hoặc Captured Image
                if (_capturedImage != null)
                  Positioned.fill(
                    child: Image.file(
                      _capturedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_isCameraInitialized)
                  Positioned.fill(
                    child: CameraPreview(_cameraController!),
                  )
                else
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Đang khởi tạo camera...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                // Scanning overlay
                if (_isScanning)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Đang nhận dạng...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Scan frame overlay
                if (_capturedImage == null && !_isScanning)
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            color: Colors.white54,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Đưa vật thể vào khung',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Info banner
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Text(
                      'Quét mèo, chó để xem mô hình 3D',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: _capturedImage != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.refresh,
                          label: 'Quét lại',
                          onTap: _resetScan,
                        ),
                        if (_scanResult?.hasMatch ?? false)
                          _buildControlButton(
                            icon: Icons.view_in_ar,
                            label: 'Xem 3D',
                            onTap: () =>
                                _navigateToViewer(_scanResult!.matchedModel!),
                            isPrimary: true,
                          ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.photo_library,
                          label: 'Thư viện',
                          onTap: _pickFromGallery,
                        ),
                        _buildCaptureButton(),
                        _buildControlButton(
                          icon: Icons.view_in_ar,
                          label: '3D Viewer',
                          onTap: () =>
                              Navigator.pushReplacementNamed(
                                context,
                                ViewerPage.routeName,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF26C6DA) : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isCameraInitialized && !_isScanning ? _captureAndScan : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chụp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
