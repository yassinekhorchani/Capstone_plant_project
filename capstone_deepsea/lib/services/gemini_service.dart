import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String _apiKey = 'AIzaSyDI5MjEpO_17zz4AlxwmBT_pS0Md6v9zB0';
  static const String _modelId = 'gemini-flash-latest'; // Same as Kotlin working version
  
  Future<String> getTreatmentAdvice({
    required String plantType,
    required String condition,
    required bool isHealthy,
    required double confidence,
  }) async {
    try {
      // Build structured prompt that returns JSON (like CV analyzer)
      final String prompt = '''You are an expert plant care advisor. A plant has been identified with the following details:

Plant Type: $plantType
${isHealthy ? 'Status: Healthy' : 'Disease Detected: $condition'}
Detection Confidence: ${confidence.toStringAsFixed(1)}%

Your goal is to provide ${isHealthy ? 'care advice' : 'treatment advice'} and return a JSON object (NO explanations, NO markdown, NO text outside JSON).
The JSON must strictly follow this structure:

{
  "sections": [
    {
      "id": "overview",
      "title": "${isHealthy ? 'Plant Care Overview' : 'Disease Overview'}",
      "icon": "${isHealthy ? 'care' : 'warning'}",
      "items": [
        "Main point 1",
        "Main point 2",
        "Main point 3"
      ]
    },
    {
      "id": "immediate",
      "title": "${isHealthy ? 'Daily Care Routine' : 'Immediate Actions (24-48 hours)'}",
      "icon": "action",
      "items": [
        "Action step 1",
        "Action step 2",
        "Action step 3"
      ]
    },
    {
      "id": "treatment",
      "title": "${isHealthy ? 'Maintenance Tips' : 'Treatment Methods'}",
      "icon": "treatment",
      "items": [
        "Treatment/care method 1",
        "Treatment/care method 2",
        "Treatment/care method 3"
      ]
    },
    {
      "id": "prevention",
      "title": "Prevention & Best Practices",
      "icon": "shield",
      "items": [
        "Prevention tip 1",
        "Prevention tip 2",
        "Prevention tip 3"
      ]
    },
    {
      "id": "timeline",
      "title": "Expected ${isHealthy ? 'Growth' : 'Recovery'} Timeline",
      "icon": "time",
      "items": [
        "Timeline detail 1",
        "Timeline detail 2",
        "Timeline detail 3"
      ]
    },
    {
      "id": "care",
      "title": "Additional Care Requirements",
      "icon": "water",
      "items": [
        "Care requirement 1",
        "Care requirement 2",
        "Care requirement 3"
      ]
    }
  ],
  "summary": {
    "severity": "${isHealthy ? 'low' : 'high'}",
    "urgency": "${isHealthy ? 'routine' : 'immediate'}",
    "successRate": "percentage or description"
  }
}

Guidelines:
- Keep each item concise (1-2 sentences max)
- Use clear, actionable language
- Provide specific, practical advice
- Include relevant measurements (water amounts, light hours, etc.)
${isHealthy ? '- Focus on optimal growing conditions' : '- Emphasize urgency and safety'}

Return only JSON, no markdown, no explanations.''';
      
      // Build request body
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };
      
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent?key=$_apiKey'
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(response.body);
        throw Exception('AI service error: HTTP ${response.statusCode}. Details: $errorMsg');
      }
      
      if (response.body.isEmpty) {
        throw Exception('AI service returned an empty response');
      }
      
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['candidates'] != null) {
        final candidates = jsonResponse['candidates'] as List;
        if (candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final firstPart = parts[0] as Map<String, dynamic>;
            final text = firstPart['text'] as String?;
            if (text != null && text.isNotEmpty) {
              return text;
            }
          }
        }
      }
      
      throw Exception('No text found in AI response');
    } catch (e) {
      throw Exception('Failed to get treatment advice: $e');
    }
  }
  
  String _extractErrorMessage(String body) {
    if (body.isEmpty) return 'No details from server.';
    try {
      final json = jsonDecode(body);
      if (json['error'] != null) {
        final error = json['error'];
        if (error is Map && error['message'] != null) {
          return error['message'];
        }
        return error.toString();
      }
      if (json['message'] != null) {
        return json['message'];
      }
      return body;
    } catch (e) {
      return body;
    }
  }
}
