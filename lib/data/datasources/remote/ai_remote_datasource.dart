import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/exceptions.dart';

abstract class AIRemoteDataSource {
  Future<String> generateResponse(List<Map<String, String>> messageHistory);
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  @override
  Future<String> generateResponse(List<Map<String, String>> messageHistory) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw ServerException(message: 'API key not found. Please set OPENAI_API_KEY in your .env file.');
    }

    final messageHistoryy = [
      {
        'role': 'system',
        'content': 'أنت مساعد ذكي عام في كل شيء. ردودك يجب أن تكون صحيحة، ومنطقية.'
      },
      ...messageHistory,
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messageHistoryy,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return decodedResponse['choices'][0]['message']['content'];
      } else {
        final errorBody = jsonDecode(response.body);
        if (errorBody['error'] != null &&
            errorBody['error']['code'] == 'insufficient_quota') {
          throw ServerException(
            message: 'لقد تجاوزت الحد المسموح به في حسابك المجاني. يرجى مراجعة تفاصيل خطة الاشتراك والفواتير.',
          );
        } else {
          throw ServerException(
            message: 'Failed to get AI response: ${response.statusCode} ${response.body}',
          );
        }
      }
    } catch (e) {
      print(e.toString());
      throw ServerException(message: 'Network error: $e');
    }
  }

}

