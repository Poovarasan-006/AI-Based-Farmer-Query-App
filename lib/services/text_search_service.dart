import 'package:ai_based_farmer_query_app/services/rag_service.dart';

class TextSearchService {
  final RAGService ragService;

  TextSearchService({required this.ragService});

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      // Use the RAG service for enhanced search capabilities
      return await ragService.search(query);
    } catch (e) {
      return [
        {
          'title': 'Search Error',
          'content': 'Unable to perform search: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  List<Map<String, dynamic>> getPopularQueries() {
    return [
      {
        'title': 'How to treat powdery mildew?',
        'content': 'Powdery mildew is a common fungal disease. Treatment includes using sulfur-based fungicides and improving air circulation.',
        'category': 'Crop Disease',
        'score': 0.9,
      },
      {
        'title': 'Best fertilizer for tomatoes',
        'content': 'Tomatoes require balanced fertilization with emphasis on phosphorus and potassium for fruit development.',
        'category': 'Fertilization',
        'score': 0.8,
      },
      {
        'title': 'Pest control methods',
        'content': 'Integrated pest management combines biological, cultural, and chemical control methods for effective pest management.',
        'category': 'Pest Management',
        'score': 0.85,
      },
      {
        'title': 'Soil preparation techniques',
        'content': 'Proper soil preparation includes testing, amendment application, and tillage to create optimal growing conditions.',
        'category': 'Soil Management',
        'score': 0.8,
      },
    ];
  }
}