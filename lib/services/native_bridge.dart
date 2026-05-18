import 'package:flutter/services.dart';

class NativeBridge {
  static const platform = MethodChannel('com.offsub.app/system');

  // Android 16 Gemini Nano 연동용 인터페이스
  static Future<String> getAiResponse(String prompt) async {
    try {
      final String result = await platform.invokeMethod('getGeminiResponse', {"prompt": prompt});
      return result;
    } on PlatformException catch (e) {
      return "AI 연결에 실패했습니다: ${e.message}";
    }
  }

  // 앱 사용 시간 가져오기 인터페이스
  static Future<List<dynamic>> getUsageStats() async {
    try {
      return await platform.invokeMethod('getUsageStats');
    } catch (e) {
      return [];
    }
  }
}
