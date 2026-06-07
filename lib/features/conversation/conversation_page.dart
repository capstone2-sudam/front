import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'conversation_service.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../../core/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../glove/glove_service.dart';

enum TranslateMode {
  signToText,
  textToSign,
}

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  TranslateMode _mode = TranslateMode.signToText;

  final TextEditingController _guideController = TextEditingController();
  final GlobalKey<_TextToSignViewState> _unityKey = GlobalKey<_TextToSignViewState>();
  final TranslationService _translationService = TranslationService();

  String _recognizedText = '수어 입력이 들어오면 여기에 한국어 결과가 표시됩니다.';
  String _generatedText = '한국어 안내 문장을 입력하면 여기에 수어 출력 준비 상태가 표시됩니다.';
  String _unityDataToDisplay = "";

  void _updateRecognizedText(String text) {
    setState(() {
      _recognizedText = text;
    });
  }

  @override
  void dispose() {
    _guideController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == TranslateMode.signToText
          ? TranslateMode.textToSign
          : TranslateMode.signToText;
    });
  }

  // 💡 수정: 텍스트를 백엔드로 보내고 Unity로 전달
  Future<void> _generateSign() async {
    final text = _guideController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _generatedText = "수어 애니메이션을 생성 중입니다...";
      _unityDataToDisplay = "백엔드에서 데이터 수신 중..."; // 로딩 표시
    });

    String? jsonResponse = await _translationService.textToSign(text);

    if (jsonResponse != null) {
      setState(() {
        _generatedText = text; 
        _unityDataToDisplay = jsonResponse; // 화면에 뿌리기 위해 변수에 저장
      });
    
      _unityKey.currentState?.sendDataToUnity(jsonResponse);
f (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백엔드 데이터를 성공적으로 수신했습니다.')),
        );
      }
    } else {
      setState(() {
        _generatedText = "생성에 실패했습니다. 다시 시도해주세요.";
        _unityDataToDisplay = "데이터 수신 실패";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeSwitcher = _ModeSwitcher(
      mode: _mode,
      onTapLeft: () => setState(() => _mode = TranslateMode.signToText),
      onTapRight: () => setState(() => _mode = TranslateMode.textToSign),
      onSwap: _toggleMode,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IndexedStack(
            index: _mode == TranslateMode.signToText ? 0 : 1,
            children: [
              _SignToTextView(
                modeSwitcher: modeSwitcher,
                recognizedText: _recognizedText,
                onTranslationResult: _updateRecognizedText,
              ),
              _TextToSignView(
                key: _unityKey,
                modeSwitcher: modeSwitcher,
                controller: _guideController,
                generatedText: _generatedText,
                onGenerate: _generateSign,
                unityDataToDisplay: _unityDataToDisplay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 모드 전환 스위치 (플로팅)
// ----------------------------------------------------
class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.mode,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onSwap,
  });

  final TranslateMode mode;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeTab(
            title: '한국수화 → 한국어',
            selected: mode == TranslateMode.signToText,
            onTap: onTapLeft,
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line.withOpacity(0.5)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onSwap,
              icon: const Icon(
                Icons.swap_vert_rounded,
                size: 24,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _ModeTab(
            title: '한국어 → 한국수화',
            selected: mode == TranslateMode.textToSign,
            onTap: onTapRight,
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.softBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.primary : AppColors.subText,
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 🌟 수어 -> 한국어 화면 (카메라)
// ----------------------------------------------------
class _SignToTextView extends StatelessWidget {
  const _SignToTextView({
    super.key,
    required this.modeSwitcher,
    required this.recognizedText,
    required this.onTranslationResult,
  });

  final Widget modeSwitcher;
  final String recognizedText;
  final Function(String) onTranslationResult;

  @override
  Widget build(BuildContext context) {
    final cameraWithOverlays = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Positioned.fill(
            child: LiveCameraView(onTranslationResult: onTranslationResult),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 140,
              child: modeSwitcher,
            ),
          ),
        ],
      ),
    );

    final resultBox = Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.translate_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                '실시간 번역 결과',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                recognizedText,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Expanded(child: cameraWithOverlays),
        const SizedBox(height: 8),
        resultBox,
      ],
    );
  }
}


// ----------------------------------------------------
// 🌟 한국어 -> 수어 화면 (아바타 더미 화면)
// ----------------------------------------------------
class _TextToSignView extends StatefulWidget {
  const _TextToSignView({
    super.key,
    required this.modeSwitcher,
    required this.controller,
    required this.generatedText,
    required this.onGenerate,
    required this.unityDataToDisplay,
  });

  final Widget modeSwitcher;
  final TextEditingController controller;
  final String generatedText;
  final VoidCallback onGenerate;
  final String unityDataToDisplay;

  @override
  State<_TextToSignView> createState() => _TextToSignViewState();
}

class _TextToSignViewState extends State<_TextToSignView> {
  // 🚧 [UNITY 연동 시 주석 해제 1]
  // UnityWidgetController? _unityWidgetController;

  // 💡 1. 유니티가 로드 완료되면 컨트롤러를 연결하는 함수
  void onUnityCreated(controller) {
    // 🚧 [UNITY 연동 시 주석 해제 2]
    // _unityWidgetController = controller;
  }
  
  // 💡 2. 부모 위젯(_generateSign)에서 호출할 수 있도록 public 메서드 생성
  void sendDataToUnity(String jsonString) {
    // 🚧 [UNITY 연동 시 주석 해제 3]
    /*
    if (_unityWidgetController != null) {
      _unityWidgetController!.postMessage('AvatarModel', 'PlaySignLanguage', jsonString);
      debugPrint('➡️ [Flutter -> Unity] 데이터 전송 성공');
    } else {
      debugPrint('❌ [Flutter -> Unity] 유니티가 아직 로드되지 않았습니다.');
    }
    */
    
    // 💡 현재는 테스트를 위해 콘솔에만 출력합니다.
    debugPrint('➡️ [DEMO] 유니티로 데이터 전송 시뮬레이션 완료:\n$jsonString');
  }

  @override
  Widget build(BuildContext context) {
    final avatarWithOverlays = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          // 💡 4. 임시 회색 박스 내부에 JSON 데이터를 출력하도록 수정
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16), // 뒤로가기 버튼을 가리지 않게 패딩
            child: SingleChildScrollView(
              child: Text( 
                widget.unityDataToDisplay.isEmpty
                    ? '이곳에 3D 아바타가\n표시될 예정입니다.'
                    : widget.unityDataToDisplay, // 💡 값이 있으면 백엔드 JSON 그대로 출력
                textAlign: widget.unityDataToDisplay.isEmpty ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontSize: widget.unityDataToDisplay.isEmpty ? 16 : 13,
                  color: widget.unityDataToDisplay.isEmpty ? Colors.grey : Colors.black87,
                  fontWeight: widget.unityDataToDisplay.isEmpty ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'monospace', // 코드가 보기 편하게 모노스페이스 폰트 적용
                ),
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 140,
              child: widget.modeSwitcher,
            ),
          ),
        ],
      ),
    );

    final inputBox = Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.keyboard_alt_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                '한국어 입력',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: '안내 문장을 입력해 주세요.',
                      hintStyle: TextStyle(color: AppColors.subText.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: PrimaryButton(
                    text: '변환',
                    onPressed: widget.onGenerate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Expanded(child: avatarWithOverlays),
        const SizedBox(height: 8),
        inputBox,
      ],
    );
  }
}

// ----------------------------------------------------
// 🌟 실시간 카메라 위젯 (가벼워진 버전)
// ----------------------------------------------------
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({
    super.key,
    required this.onTranslationResult,
  });

  final Function(String) onTranslationResult;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String? _errorMessage;
  bool _isRecording = false;
  late AnimationController _blinkController;

  final TranslationService _translationService = TranslationService();
  final GloveService _gloveService = GloveService();

  int _startTimestamp = 0; // 녹화 시작 서버 시간 저장 

  String _leftGloveId = ""; 
  String _rightGloveId = "";

  @override
  void initState() {
    super.initState();
    _initCamera();

    _fetchUserGloves();
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<void> _fetchUserGloves() async {
    final gloves = await _gloveService.getGloves();
    debugPrint('📥 [DEBUG] API 응답 장갑 원본 데이터: $gloves'); 
    
    if (!mounted) return;
    
    // 💡 1. 새로 데이터를 매칭하기 전에 기존 변수를 빈 문자열로 싹 비워줍니다.
    _leftGloveId = "";
    _rightGloveId = "";

    for (var glove in gloves) {
      // 💡 2. 장갑의 상태가 'ACTIVE' 켜져 있는 상태일 때만 변수에 담습니다!
      if (glove['status'] == 'ACTIVE') {
        final id = glove['gloveId'] ?? glove['deviceId'] ?? '';

        final isConnected = await _gloveService.checkGloveConnection(id);
        if (!isConnected) {
          debugPrint('⚠️ [DEBUG] 장갑 $id 가 활성 상태이나 연결되어 있지 않습니다.');
        }
      
        if (glove['direction'] == 'L') {
          _leftGloveId = id;
        } else if (glove['direction'] == 'R') {
          _rightGloveId = id;
        }
      }
      // 🔍 3. 최종적으로 변수에 잘 들어갔는지 확인합니다.
      debugPrint('🧤 [DEBUG] 최종 적용된 장갑 - Left: $_leftGloveId, Right: $_rightGloveId');
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = '카메라를 찾을 수 없습니다.');
        return;
      }

      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      try {
        final minZoom = await _controller!.getMinZoomLevel();
        await _controller!.setZoomLevel(minZoom);
      } catch (e) {
        debugPrint('줌 아웃 설정 실패: $e');
      }

      setState(() {
        _isCameraInitialized = true;
      });

    } catch (e) {
      setState(() => _errorMessage = '카메라 초기화 오류:\n$e');
    }
  }

  // 녹화 토클 함수 수정
  Future<void> _toggleRecording() async {
    if (!_isCameraInitialized || _controller == null) return;

    if (_isRecording) {
      // ===== ⏹️ 녹화 종료 프로세스 =====
      setState(() => _isRecording = false);
      _blinkController.stop();
      _blinkController.value = 1.0;

      try {
        // 💡 [최적화 1] 카메라가 꺼지기 전에 장갑부터 즉시 정지시킵니다!
        // (await를 쓰지 않거나 순서를 맨 위로 올려서 딜레이를 최소화합니다)
        if (_leftGloveId.isNotEmpty) {
          await _translationService.sendGloveCommand(_leftGloveId, "END");
        }
        if (_rightGloveId.isNotEmpty) {
          await _translationService.sendGloveCommand(_rightGloveId, "END");
        }

        // 💡 [최적화 2] 그 다음, 영상 녹화를 중지하고 mp4 파일을 획득합니다. (약 0.5초 소요)
        final XFile videoFile = await _controller!.stopVideoRecording();

        // UI에 로딩 스낵바 표시
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 서버에서 번역 중입니다...')));

        // 💡 [최적화 3] 저장된 영상과 시작 타임스탬프를 백엔드로 POST 전송합니다.
        final String? resultText = await _translationService.translateSignVideo(
            videoFile.path, 
            _startTimestamp, 
            _leftGloveId, 
            _rightGloveId
        );

        if (mounted && resultText != null) {
          // widget.onTranslationResult(resultText);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 서버 통신 완료!')));
        }
      } catch (e) {
        debugPrint('녹화 종료/전송 에러: $e');
      }
    } else {
      // ===== 🔴 녹화 시작 프로세스 =====
      // 여기서 연결 상태를 체크합니다!
      bool isLeftReady = _leftGloveId.isEmpty || await _gloveService.checkGloveConnection(_leftGloveId);
      bool isRightReady = _rightGloveId.isEmpty || await _gloveService.checkGloveConnection(_rightGloveId);
      
      // if (!isLeftReady || !isRightReady) {
      //   if (!mounted) return;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('⚠️ 장갑이 연결되지 않아 영상 데이터만으로 번역합니다.')),
      //   );
      //   return; 
      // }

      if (!mounted) return;
      
      try {
        // 1. 서버 시간 동기화 (오프셋 계산)
        int serverTime = await _translationService.getServerTime();
        int localTime = DateTime.now().millisecondsSinceEpoch;
        int offset = serverTime - localTime;

        // 2. 장갑에 START 명령 전송
        if (_leftGloveId.isNotEmpty) {
          await _translationService.sendGloveCommand(_leftGloveId, "START");
        }
        if (_rightGloveId.isNotEmpty) {
          await _translationService.sendGloveCommand(_rightGloveId, "START");
        }

       // 3. 현재 동기화된 시간으로 타임스탬프 저장 후 녹화 시작
       _startTimestamp = DateTime.now().millisecondsSinceEpoch + offset;
        await _controller!.startVideoRecording();

        setState(() => _isRecording = true);
        _blinkController.repeat(reverse: true);

      } catch (e) {
        debugPrint('녹화 시작 에러: $e');
      }
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (!_isCameraInitialized || _controller == null) return const Center(child: CircularProgressIndicator());

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    double ratio = _controller!.value.aspectRatio;
    if (isLandscape && ratio < 1.0) ratio = 1.0 / ratio;
    else if (!isLandscape && ratio > 1.0) ratio = 1.0 / ratio;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: ratio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),

              if (_isRecording)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent.withOpacity(0.8), width: 6),
                  ),
                ),

              // 상단: 카메라 활성화 상태 표시 바
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '📸 카메라 활성화 됨',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              if (_isRecording)
                Positioned(
                  top: 25,
                  left: 20,
                  child: FadeTransition(
                    opacity: _blinkController,
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isRecording ? 30 : 56,
                          height: _isRecording ? 30 : 56,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(_isRecording ? 8 : 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}