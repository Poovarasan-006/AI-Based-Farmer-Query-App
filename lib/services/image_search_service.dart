import 'dart:io';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';

class ImageSearchService {
  final RAGService ragService;

  ImageSearchService({required this.ragService});

  Future<String> analyzeImage(File imageFile) async {
    try {
      // In a real implementation, this would integrate with an image analysis API
      // For now, we'll simulate analysis based on file properties
      
      final fileSize = imageFile.lengthSync();
      final fileName = imageFile.path.split('/').last.toLowerCase();
      
      if (fileName.contains('leaf') || fileName.contains('plant')) {
        return 'Analysis shows potential leaf disease. Recommend checking for fungal infections and applying appropriate fungicides.';
      } else if (fileName.contains('soil') || fileName.contains('ground')) {
        return 'Soil analysis indicates need for organic matter improvement. Recommend adding compost and testing pH levels.';
      } else if (fileName.contains('insect') || fileName.contains('pest')) {
        return 'Pest identification suggests aphid infestation. Recommend using neem oil or introducing beneficial insects.';
      } else if (fileName.contains('crop') || fileName.contains('field')) {
        return 'Field analysis shows healthy crop growth. Continue with current management practices.';
      } else {
        return 'Image analysis complete. No specific issues detected. Recommend regular monitoring.';
      }
    } catch (e) {
      return 'Error analyzing image: $e';
    }
  }

  Future<List<Map<String, dynamic>>> searchByImage(File imageFile) async {
    try {
      final analysis = await analyzeImage(imageFile);
      return await ragService.search(analysis);
    } catch (e) {
      return [
        {
          'title': 'Image Search Error',
          'content': 'Unable to process image search: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  List<String> getImageAnalysisTips() {
    return [
      'Ensure good lighting when capturing images',
      'Focus on the affected area for better analysis',
      'Capture multiple angles if possible',
      'Include a reference object for scale',
      'Clean camera lens for clear images',
    ];
  }
}