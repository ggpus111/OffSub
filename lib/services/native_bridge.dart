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

  // 사용 정보 접근 권한 설정 화면 열기. 네이티브 구현이 없으면 false를 반환합니다.
  static Future<bool> openUsageAccessSettings() async {
    try {
      final result = await platform.invokeMethod('openUsageAccessSettings');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasSmsPermission() async {
    try {
      final result = await platform.invokeMethod('hasSmsPermission');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestSmsPermission() async {
    try {
      final result = await platform.invokeMethod('requestSmsPermission');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getSmsMessages({int limit = 500}) async {
    try {
      final result = await platform.invokeMethod('getSmsMessages', {'limit': limit});
      if (result is! List) return [];
      return result
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
