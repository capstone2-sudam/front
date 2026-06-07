import '../../core/api_client.dart';
import 'package:dio/dio.dart';

class GloveService {
  final Dio _dio = ApiClient().dio;

  // 1. 내 장갑 목록 조회
  Future<List<dynamic>> getGloves() async {
    try {
      final response = await _dio.get('/gloves');
      if (response.statusCode == 200) {
        return response.data; // List<dynamic> 반환 (각 항목은 Map<String, dynamic>)
      }
    } catch (e) {
      print('장갑 목록 조회 실패: $e');
    }
    return [];
  }

  // 2. 장갑 등록
  Future<bool> addGlove(String deviceId, String nickname) async {
    try {
      final response = await _dio.post('/gloves', data: {
        'deviceId': deviceId,
        'nickname': nickname,
      });
      // 백엔드 SuccessResponseDTO 응답 처리
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('장갑 등록 실패: $e');
    }
    return false;
  }

  // 3. 장갑 삭제
  Future<bool> deleteGlove(String gloveId) async {
    try {
      final response = await _dio.delete('/gloves/$gloveId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('장갑 삭제 실패: $e');
    }
    return false;
  }
  
  // 💡 4. 장갑 상태 업데이트 (ACTIVE / INACTIVE)
  Future<bool> updateGloveStatus(String gloveId, String status) async {
    try {
      final response = await _dio.put('/gloves/$gloveId/status', data: {
        'status': status,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('장갑 상태 업데이트 실패: $e');
    }
    return false;
  }

  Future<bool> checkGloveConnection(String gloveId) async {
    try {
      final response = await _dio.get('/ws/glove/$gloveId/status');
      if (response.statusCode == 200) {
        return response.data['isConnected'] ?? false;
      }
    } catch (e) {
      print('연결 상태 확인 실패: $e');
    }
    return false; // 에러 시 끊긴 것으로 간주
  }
  
  Future<bool> sendGloveCommand(String gloveId, String command) async {
  try {
    // 💡 data 대신 queryParameters를 사용합니다.
    final response = await _dio.post(
      '/ws/glove/$gloveId/command', 
      queryParameters: {'command': command} 
    );
    return response.statusCode == 200;
  } catch (e) {
      print('명령 전송 실패: $e');
      return false;
    }
  }
}