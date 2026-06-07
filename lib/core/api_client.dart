// lib/core/api_client.dart
// Dio 설정과 토큰 인터셉터(통신 기본 설정)
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // 1. 기본 옵션 설정 (Base URL, 타임아웃 등)
    dio = Dio(BaseOptions(
      baseUrl: 'http://10.73.146.83:8000',
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(minutes: 15),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('sessionToken');
        
        if (token != null && token.isNotEmpty) {
          options.headers['sessionToken'] = token;
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print('API 에러 발생: ${e.response?.statusCode}');
        return handler.next(e);
      },
    ));
  }

  // ==========================================
  // 1. 회원 관련 API
  // ==========================================
  // 로그인
  Future<bool> login(String loginId, String password) async {
    try {
      final response = await dio.post('/users/login', data: {
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
      final response = await dio.post('/users/signup', data: {
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
      final response = await dio.post('/users/logout');
      
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
      final response = await dio.get('/users/me');
      
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
      final response = await dio.delete('/users/me');
      
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

  // ==========================================
  // 2. 장갑 관련 API
  // ==========================================
  Future<List<dynamic>> getGloves() async {
    try {
      final response = await dio.get('/gloves');
      return response.data; 
    } catch (e) {
      print('장갑 목록 조회 실패: $e');
      return [];
    }
  }

  Future<bool> addGlove(String deviceId, String nickname) async {
    try {
      final response = await dio.post('/gloves', data: {
        'deviceId': deviceId,
        'nickname': nickname,
      });
      return response.statusCode == 200;
    } catch(e) {
      print('장갑 등록 실패: $e');
      return false;
    }
  }

  Future<bool> deleteGlove(String gloveId) async {
    try {
      final response = await dio.delete('/gloves/$gloveId');
      return response.statusCode == 200;
    } catch (e) {
      print('장갑 삭제 실패: $e');
      return false;
    }
  }
  
  // ==========================================
  // 3. 번역 관련 API
  // ==========================================
  
  // 💡 장갑에 START/STOP 명령 전송
  Future<bool> sendGloveCommand(String gloveId, String command) async {
    try {
      final response = await dio.post('/ws/glove/$gloveId/command?command=$command');
      return response.statusCode == 200;
    } catch (e) {
      print('장갑 명령 전송 실패: $e');
      return false;
    }
  }

  // 💡 녹화된 영상(.mp4)을 백엔드로 업로드하여 번역 요청
  Future<String?> translateSignVideo(String filePath) async {
    try {
      // 파일을 Multipart 폼 데이터로 변환
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'sign_video.mp4'),
      });

      // 백엔드의 영상 업로드 API 호출 (라우터 수정 필요)
      final response = await dio.post('/translations/sign-to-text/video', data: formData);
      
      if (response.statusCode == 200) {
        return response.data['textContent']; // 번역된 텍스트 반환
      }
    } catch (e) {
      print('수어 영상 번역 실패: $e');
    }
    return null;
  }

  Future<String?> textToSign(String inputText) async {
    try {
      final response = await dio.post('/translations/text-to-sign', data: {
        'inputText': inputText,
      });
      if (response.statusCode == 200) {
        return response.data; // 서버에서 오는 JSON 데이터 반환
      }
    } catch (e) {
      print('텍스트->수어 번역 실패: $e');
    }
    return null;
  }

  Future<String?> signToText(Map<String, dynamic> videoPackageData) async {
    try {
      final response = await dio.post('/translations/sign-to-text', data: videoPackageData);
      if (response.statusCode == 200) {
        return response.data['textContent'];
      }
    } catch (e) {
      print('수어->텍스트 번역 실패: $e');
    }
    return null;
  }
}