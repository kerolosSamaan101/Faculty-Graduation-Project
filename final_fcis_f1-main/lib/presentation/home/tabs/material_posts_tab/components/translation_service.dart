import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  final Dio _dio = Dio();
  static const String _baseUrl = "http://192.168.1.17:5002";

  Future<String> translateCodeMixedText(String text) async {
    if (!_containsArabic(text)) {
      return text; // Return original if no Arabic found
    }

    try {
      final response = await _dio.post(
        "$_baseUrl/translate",
        data: {"text": text},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return response.data['translated_text'] ?? text;
      }
      return text; // Fallback to original if translation fails
    } catch (e) {
      if (kDebugMode) {
        print("Translation error: $e");
      }
      return text; // Fallback to original if error occurs
    }
  }

  bool _containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }
}
