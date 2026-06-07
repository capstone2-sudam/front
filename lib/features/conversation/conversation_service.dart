import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'dart:convert';

class TranslationService {
  final Dio _dio = ApiClient().dio;

  // 1. 서버 NTP 시간 가져오기
  Future<int> getServerTime() async {
    final response = await _dio.get('/ws/server-time');
    return response.data['serverTime'];
  }

  // 2. 장갑 START / STOP 제어
  Future<bool> sendGloveCommand(String gloveId, String command) async {
    try {
      final response = await _dio.post(
        '/ws/glove/$gloveId/command',
        queryParameters: {'command': command},
      );
      return response.data['success'] == true;
    } catch (e) {
      print('장갑 $command 명령 전송 실패 ($gloveId): $e');
      return false;
    }
  }

  // 3. 수어 영상(.mp4) 업로드 (Sign to Text)
  Future<String?> translateSignVideo(String filePath, int startTimestamp, String leftGloveId, String rightGloveId) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'sign_video.mp4'),
        'start_timestamp': startTimestamp,
        'left_glove_id': leftGloveId.isEmpty ? '' : leftGloveId,
        'right_glove_id': rightGloveId.isEmpty ? '' : rightGloveId,
      });

      final response = await _dio.post('/translations/sign-to-text/video', data: formData);
      if (response.statusCode == 200) {
        // 💡 백엔드의 alias 설정에 맞춰 'textContent' 키를 사용하여 꺼내야 합니다!
        if (response.data['success'] == true) {
           return response.data['textContent']; 
        } else {
           // 서버에서 success: False (에러)로 보냈을 때의 처리
           return response.data['textContent']; 
        }
      }
    } catch (e) {
      print('수어 영상 번역 실패: $e');
    }
    return null;
  }

  // 4. 한국어 텍스트 -> 수어 (Text to Sign)
  Future<String?> textToSign(String text) async {
    try {
      final response = await _dio.post('/translations/text-to-sign', data: {
        'inputText': text,
      });
      if (response.statusCode == 200) {
        // 🟢 수정됨: Dart 객체를 완벽한 표준 JSON 문자열로 변환해서 반환합니다.
        return jsonEncode(response.data);
      }
    } catch (e) {
      print('텍스트->수어 변환 실패: $e');
    }
    return null;
  }
}