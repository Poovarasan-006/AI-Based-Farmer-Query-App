import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_based_farmer_query_app/datasets/crop_diseases_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/pest_management_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/soil_management_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/external_datasets.dart';

class RAGService {
  final String? apiKey;
  final String apiUrl;
  final ExternalDatasets? externalDatasets;

  RAGService({this.apiKey, this.apiUrl = 'https://api.openai.com/v1/chat/completions', this.externalDatasets});

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      // First, get relevant documents from our datasets
      final relevantDocs = _retrieveRelevantDocuments(query);
      
      if (relevantDocs.isEmpty) {
        return [
          {
            'title': 'No Results Found',
            'content': 'No relevant information found for your query. Please try with different keywords.',
            'category': 'General',
            'score': 0.0,
          }
        ];
      }

      // If we have an API key, use AI to generate response
      if (apiKey != null && apiKey!.isNotEmpty) {
        final response = await _generateAIResponse(query, relevantDocs);
        return response;
      } else {
        // Fallback to dataset-based responses
        return _generateDatasetResponse(query, relevantDocs);
      }
    } catch (e) {
      return [
        {
          'title': 'Error',
          'content': 'An error occurred while processing your query: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  List<Map<String, dynamic>> _retrieveRelevantDocuments(String query) {
    final queryLower = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    // Search crop diseases dataset
    if (queryLower.contains('disease') || 
        queryLower.contains('powdery') || 
        queryLower.contains('blight') ||
        queryLower.contains('rust') ||
        queryLower.contains('wilt')) {
      
      results.add({
        'title': 'Crop Diseases Information',
        'content': _formatCropDiseasesData(),
        'category': 'Crop Disease',
        'source': 'Crop Diseases Dataset',
      });
    }

    // Search pest management dataset
    if (queryLower.contains('pest') || 
        queryLower.contains('insect') || 
        queryLower.contains('worm') ||
        queryLower.contains('fly') ||
        queryLower.contains('mite')) {
      
      results.add({
        'title': 'Pest Management Guide',
        'content': _formatPestManagementData(),
        'category': 'Pest Management',
        'source': 'Pest Management Dataset',
      });
    }

    // Search soil management dataset
    if (queryLower.contains('soil') || 
        queryLower.contains('fertilizer') || 
        queryLower.contains('compost') ||
        queryLower.contains('nutrient') ||
        queryLower.contains('amendment')) {
      
      results.add({
        'title': 'Soil Management Practices',
        'content': _formatSoilManagementData(),
        'category': 'Soil Management',
        'source': 'Soil Management Dataset',
      });
    }

    // If no specific category matches, return general information
    if (results.isEmpty) {
      results.add({
        'title': 'General Agricultural Information',
        'content': 'This query requires more specific information. Please specify if you are looking for crop disease information, pest management, or soil management.',
        'category': 'General',
        'source': 'General Knowledge',
      });
    }

    return results;
  }

  String _formatCropDiseasesData() {
    final buffer = StringBuffer();
    buffer.writeln('## Crop Diseases and Management');
    buffer.writeln('');
    
    // Add some key diseases with high relevance
    final diseases = [
      'Powdery Mildew',
      'Blight', 
      'Downy Mildew',
      'Rust',
      'Fusarium Wilt'
    ];

    diseases.forEach((disease) {
      buffer.writeln('### $disease');
      buffer.writeln('- **Affected Crops**: Various vegetables and fruits');
      buffer.writeln('- **Symptoms**: Characteristic symptoms for each disease');
      buffer.writeln('- **Treatments**: Fungicides and cultural practices');
      buffer.writeln('- **Prevention**: Crop rotation and resistant varieties');
      buffer.writeln('');
    });

    buffer.writeln('### General Prevention Tips:');
    buffer.writeln('- Practice crop rotation');
    buffer.writeln('- Use disease-resistant varieties');
    buffer.writeln('- Maintain proper spacing between plants');
    buffer.writeln('- Avoid overhead watering');
    buffer.writeln('- Remove infected plant material promptly');

    return buffer.toString();
  }

  String _formatPestManagementData() {
    final buffer = StringBuffer();
    buffer.writeln('## Pest Management Strategies');
    buffer.writeln('');
    
    buffer.writeln('### Common Pests and Control Methods:');
    buffer.writeln('');
    
    final pests = [
      'Armyworm',
      'Stemborers', 
      'Whiteflies',
      'Mites',
      'Bollworms'
    ];

    pests.forEach((pest) {
      buffer.writeln('### $pest');
      buffer.writeln('- **Identification**: Description of the pest');
      buffer.writeln('- **Damage**: Type of damage caused');
      buffer.writeln('- **Control Methods**: Integrated pest management strategies');
      buffer.writeln('');
    });

    buffer.writeln('### IPM (Integrated Pest Management) Principles:');
    buffer.writeln('- Monitor pest populations regularly');
    buffer.writeln('- Use biological control agents when possible');
    buffer.writeln('- Apply chemical controls only when necessary');
    buffer.writeln('- Practice good sanitation in fields');
    buffer.writeln('- Encourage beneficial insects');

    return buffer.toString();
  }

  String _formatSoilManagementData() {
    final buffer = StringBuffer();
    buffer.writeln('## Soil Management and Fertility');
    buffer.writeln('');
    
    buffer.writeln('### Soil Types and Characteristics:');
    buffer.writeln('');
    
    final soilTypes = [
      'Sandy',
      'Clay', 
      'Silty',
      'Loamy'
    ];

    soilTypes.forEach((soilType) {
      buffer.writeln('### $soilType Soil');
      buffer.writeln('- **Characteristics**: Key properties');
      buffer.writeln('- **Amendments**: Recommended soil improvements');
      buffer.writeln('- **Testing Guidelines**: How to test and monitor');
      buffer.writeln('');
    });

    buffer.writeln('### Soil Health Practices:');
    buffer.writeln('- Conduct regular soil testing');
    buffer.writeln('- Apply organic matter and compost');
    buffer.writeln('- Use cover crops during fallow periods');
    buffer.writeln('- Practice conservation tillage');
    buffer.writeln('- Maintain proper crop rotation');

    return buffer.toString();
  }

  Future<List<Map<String, dynamic>>> _generateAIResponse(
    String query, 
    List<Map<String, dynamic>> relevantDocs
  ) async {
    try {
      final prompt = _buildPrompt(query, relevantDocs);
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an agricultural expert providing helpful and accurate information to farmers. Use the provided context to answer the query.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return [
          {
            'title': 'AI-Generated Response',
            'content': content,
            'category': 'AI Response',
            'score': 1.0,
          }
        ];
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to dataset response if AI fails
      return _generateDatasetResponse(query, relevantDocs);
    }
  }

  String _buildPrompt(String query, List<Map<String, dynamic>> relevantDocs) {
    final context = relevantDocs.map((doc) => doc['content']).join('\n\n');
    
    return '''
    Context: $context
    
    Query: $query
    
    Please provide a helpful and accurate response to the farmer's query based on the context provided. 
    Focus on practical advice and actionable recommendations.
    Keep the response concise and easy to understand.
    ''';
  }

  List<Map<String, dynamic>> _generateDatasetResponse(
    String query, 
    List<Map<String, dynamic>> relevantDocs
  ) {
    // Simple keyword-based response generation
    final queryLower = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    if (queryLower.contains('how to') || queryLower.contains('treat')) {
      results.add({
        'title': 'Treatment Recommendations',
        'content': 'Based on your query, here are some general treatment recommendations:\n\n1. Identify the specific problem first\n2. Use appropriate cultural practices\n3. Apply recommended treatments\n4. Monitor results and adjust as needed',
        'category': 'Treatment',
        'score': 0.8,
      });
    } else if (queryLower.contains('prevent') || queryLower.contains('avoid')) {
      results.add({
        'title': 'Prevention Strategies',
        'content': 'Prevention is key in agriculture. Consider these strategies:\n\n1. Use disease-resistant varieties\n2. Practice proper crop rotation\n3. Maintain field sanitation\n4. Monitor for early signs of problems',
        'category': 'Prevention',
        'score': 0.8,
      });
    } else {
      results.add({
        'title': 'General Information',
        'content': 'Here is some general information related to your query based on our agricultural datasets.',
        'category': 'General',
        'score': 0.6,
      });
    }

    return results;
  }

  /// Enhanced search with external datasets integration
  Future<List<Map<String, dynamic>>> searchWithExternalData(
    String query, {
    String? cropType,
    String? region,
    String? location,
  }) async {
    try {
      // Get basic dataset results
      final basicResults = _retrieveRelevantDocuments(query);
      
      // If external datasets are available, fetch additional data
      if (externalDatasets != null && (cropType != null || region != null)) {
        try {
          final externalData = await externalDatasets!.fetchComprehensiveData(
            cropType: cropType ?? 'general',
            region: region ?? 'India',
            location: location,
          );

          // Add external data to results
          if (externalData.containsKey('crop_yield')) {
            basicResults.add({
              'title': 'Crop Yield Information',
              'content': _formatExternalCropData(externalData['crop_yield']),
              'category': 'Crop Information',
              'source': 'USDA/FAO',
            });
          }

          if (externalData.containsKey('pest_disease')) {
            basicResults.add({
              'title': 'Pest and Disease Data',
              'content': _formatExternalPestData(externalData['pest_disease']),
              'category': 'Pest Management',
              'source': 'FAO',
            });
          }

          if (externalData.containsKey('soil_data')) {
            basicResults.add({
              'title': 'Soil Analysis',
              'content': _formatExternalSoilData(externalData['soil_data']),
              'category': 'Soil Management',
              'source': 'SoilGrids',
            });
          }

          if (externalData.containsKey('market_prices')) {
            basicResults.add({
              'title': 'Market Prices',
              'content': _formatExternalMarketData(externalData['market_prices']),
              'category': 'Market Information',
              'source': 'Agmarknet',
            });
          }

          if (externalData.containsKey('weather')) {
            basicResults.add({
              'title': 'Weather Information',
              'content': _formatExternalWeatherData(externalData['weather']),
              'category': 'Weather',
              'source': 'OpenWeather',
            });
          }
        } catch (e) {
          // If external data fails, continue with basic results
          print('External data fetch failed: $e');
        }
      }

      // Generate AI response if API key is available
      if (apiKey != null && apiKey!.isNotEmpty) {
        return await _generateAIResponse(query, basicResults);
      } else {
        return basicResults;
      }
    } catch (e) {
      return [
        {
          'title': 'Search Error',
          'content': 'An error occurred while processing your query: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  String _formatExternalCropData(List<dynamic> cropData) {
    final buffer = StringBuffer();
    buffer.writeln('## External Crop Data');
    buffer.writeln('');
    
    for (var crop in cropData.take(3)) {
      buffer.writeln('### ${crop['name'] ?? 'Crop'}');
      buffer.writeln('- **Source**: ${crop['source'] ?? 'Unknown'}');
      buffer.writeln('- **Description**: ${crop['description'] ?? 'No description available'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalPestData(List<dynamic> pestData) {
    final buffer = StringBuffer();
    buffer.writeln('## External Pest Data');
    buffer.writeln('');
    
    for (var pest in pestData.take(3)) {
      buffer.writeln('### ${pest['pest_name'] ?? 'Pest'}');
      buffer.writeln('- **Description**: ${pest['description'] ?? 'No description available'}');
      buffer.writeln('- **Control Methods**: ${pest['control_methods']?.join(', ') ?? 'Not specified'}');
      buffer.writeln('- **Source**: ${pest['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalSoilData(List<dynamic> soilData) {
    final buffer = StringBuffer();
    buffer.writeln('## External Soil Data');
    buffer.writeln('');
    
    for (var soil in soilData.take(2)) {
      buffer.writeln('### ${soil['soil_type'] ?? 'Soil Type'}');
      buffer.writeln('- **pH Level**: ${soil['ph_level'] ?? 'Unknown'}');
      buffer.writeln('- **Organic Matter**: ${soil['organic_matter'] ?? 'Unknown'}%');
      buffer.writeln('- **Source**: ${soil['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalMarketData(List<dynamic> marketData) {
    final buffer = StringBuffer();
    buffer.writeln('## External Market Data');
    buffer.writeln('');
    
    for (var price in marketData.take(3)) {
      buffer.writeln('### ${price['market'] ?? 'Market'}');
      buffer.writeln('- **Price**: ₹${price['price'] ?? 'N/A'}/quintal');
      buffer.writeln('- **Date**: ${price['date'] ?? 'Unknown'}');
      buffer.writeln('- **Variety**: ${price['variety'] ?? 'Unknown'}');
      buffer.writeln('- **Source**: ${price['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalWeatherData(Map<String, dynamic> weatherData) {
    final buffer = StringBuffer();
    buffer.writeln('## External Weather Data');
    buffer.writeln('');
    
    buffer.writeln('### Current Conditions');
    buffer.writeln('- **Temperature**: ${weatherData['temperature'] ?? 'Unknown'}°C');
    buffer.writeln('- **Humidity**: ${weatherData['humidity'] ?? 'Unknown'}%');
    buffer.writeln('- **Precipitation**: ${weatherData['precipitation'] ?? 'Unknown'} mm');
    buffer.writeln('- **Wind Speed**: ${weatherData['wind_speed'] ?? 'Unknown'} km/h');
    buffer.writeln('- **Weather**: ${weatherData['weather'] ?? 'Unknown'}');
    buffer.writeln('- **Source**: ${weatherData['source'] ?? 'Unknown'}');

    return buffer.toString();
  }
}