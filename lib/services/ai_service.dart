import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String? apiKey;
  final String apiUrl;

  AIService({this.apiKey, this.apiUrl = 'https://api.openai.com/v1/chat/completions'});

  Future<String> query(String prompt) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return 'AI service not configured. Please provide an API key.';
    }

    try {
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
              'content': 'You are an agricultural expert providing helpful and accurate information to farmers.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: API request failed with status ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: Failed to connect to AI service - $e';
    }
  }

  Future<String> generateAdvisory(String cropType, String soilType, String season) async {
    final prompt = '''
    Generate a personalized agricultural advisory for a farmer growing $cropType in $soilType soil during $season season.
    
    Please provide:
    1. Crop management recommendations
    2. Fertilization guidelines
    3. Pest and disease prevention tips
    4. Irrigation recommendations
    5. Harvest timing advice
    
    Keep the response practical and actionable for small-scale farmers.
    ''';

    return await query(prompt);
  }
}
