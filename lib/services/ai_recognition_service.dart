import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Model data class để lưu thông tin về model 3D
class Model3DInfo {
  final String name;
  final String modelUrl;
  final String thumbnailUrl;

  const Model3DInfo({
    required this.name,
    required this.modelUrl,
    this.thumbnailUrl = '',
  });
}

/// Service để nhận dạng vật thể và trả về model 3D tương ứng
class AIRecognitionService {
  static final AIRecognitionService _instance = AIRecognitionService._internal();
  factory AIRecognitionService() => _instance;
  AIRecognitionService._internal();

  ImageLabeler? _imageLabeler;

  /// Map các label với model 3D tương ứng
  /// Bạn có thể thêm nhiều vật thể và model URL vào đây
  static final Map<String, Model3DInfo> _labelToModel = {
    // Mèo
    'cat': Model3DInfo(
      name: 'Cat',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb',
    ),
    'kitten': Model3DInfo(
      name: 'Kitten',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb',
    ),
    'tabby cat': Model3DInfo(
      name: 'Tabby Cat',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb',
    ),
    // Chó
    'dog': Model3DInfo(
      name: 'Dog',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
    ),
    'puppy': Model3DInfo(
      name: 'Puppy',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
    ),
    'golden retriever': Model3DInfo(
      name: 'Golden Retriever',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
    ),
    'labrador retriever': Model3DInfo(
      name: 'Labrador',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
    ),
    // Thêm các vật thể khác ở đây
    'horse': Model3DInfo(
      name: 'Horse',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
    ),
    'person': Model3DInfo(
      name: 'Astronaut',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
    ),
    'human': Model3DInfo(
      name: 'Astronaut',
      modelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
    ),
  };

  /// Khởi tạo image labeler
  Future<void> initialize() async {
    if (_imageLabeler != null) return;
    
    final options = ImageLabelerOptions(confidenceThreshold: 0.5);
    _imageLabeler = ImageLabeler(options: options);
  }

  /// Nhận dạng vật thể từ file ảnh
  /// Trả về danh sách các label được phát hiện
  Future<List<RecognizedObject>> recognizeFromFile(File imageFile) async {
    await initialize();
    
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _imageLabeler!.processImage(inputImage);
    
    return labels.map((label) => RecognizedObject(
      label: label.label,
      confidence: label.confidence,
      index: label.index,
    )).toList();
  }

  /// Lấy model 3D phù hợp nhất với các label được nhận dạng
  /// Trả về Model3DInfo nếu tìm thấy, null nếu không
  Model3DInfo? getMatchingModel(List<RecognizedObject> recognizedObjects) {
    for (final obj in recognizedObjects) {
      final labelLower = obj.label.toLowerCase();
      
      // Tìm exact match trước
      if (_labelToModel.containsKey(labelLower)) {
        return _labelToModel[labelLower];
      }
      
      // Tìm partial match
      for (final entry in _labelToModel.entries) {
        if (labelLower.contains(entry.key) || entry.key.contains(labelLower)) {
          return entry.value;
        }
      }
    }
    return null;
  }

  /// Nhận dạng và trả về model 3D trực tiếp
  Future<ScanResult> scanAndGetModel(File imageFile) async {
    final recognizedObjects = await recognizeFromFile(imageFile);
    final model = getMatchingModel(recognizedObjects);
    
    return ScanResult(
      recognizedObjects: recognizedObjects,
      matchedModel: model,
    );
  }

  /// Lấy danh sách tất cả các vật thể được hỗ trợ
  static List<String> getSupportedObjects() {
    return _labelToModel.keys.toList();
  }

  /// Giải phóng resources
  void dispose() {
    _imageLabeler?.close();
    _imageLabeler = null;
  }
}

/// Class để lưu thông tin vật thể được nhận dạng
class RecognizedObject {
  final String label;
  final double confidence;
  final int index;

  RecognizedObject({
    required this.label,
    required this.confidence,
    required this.index,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// Class để lưu kết quả quét
class ScanResult {
  final List<RecognizedObject> recognizedObjects;
  final Model3DInfo? matchedModel;

  ScanResult({
    required this.recognizedObjects,
    this.matchedModel,
  });

  bool get hasMatch => matchedModel != null;
}
