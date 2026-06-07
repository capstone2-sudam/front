// lib/features/auth/auth_service.dart

import '../../core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _dio = ApiClient().dio;

  Future<bool> login(String loginId, String password) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'loginId': loginId,
        'password': password,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        // 백엔드의 CamelModel 덕분에 'sessi  onToken'으로 바로 꺼낼 수 있습니다.
        await prefs.setString('sessionToken', response.data['sessionToken']);
        return true;
      }
    } catch (e) {
      print('로그인 실패: $e');
    }
    return false;
  }

  // 회원가입
  Future<bool> signup(String name, String loginId, String password) async {
    try {
      final response = await _dio.post('/users/signup', data: {
        'name': name,
        'loginId': loginId,
        'password': password,
      });
      // 성공하면 true 반환 (statusCode 200)
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('회원가입 실패: $e');
      return false;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      final response = await _dio.post('/users/logout');
      
      if (response.statusCode == 200) {
        // 백엔드에서 세션이 삭제되었으므로, 앱(기기)에 저장된 토큰도 지워줍니다.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('sessionToken');
        return true;
      }
    } catch (e) {
      print('로그아웃 실패: $e');
    }
    return false;
  }

  // 내 정보 조회
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await _dio.get('/users/me');
      
      if (response.statusCode == 200) {
        // { "loginId": "...", "name": "...", "createdAt": "..." } 형태의 데이터 반환
        return response.data;
      }
    } catch (e) {
      print('내 정보 조회 실패: $e');
    }
    return null;
  }

  // 회원 탈퇴
  Future<bool> deleteMyAccount() async {
    try {
      final response = await _dio.delete('/users/me');
      
      if (response.statusCode == 200) {
        // 백엔드에서 탈퇴 처리 및 세션 파기가 완료되었으므로, 앱의 토큰도 삭제합니다.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('sessionToken');
        return true;
      }
    } catch (e) {
      print('회원탈퇴 실패: $e');
    }
    return false;
  }
}