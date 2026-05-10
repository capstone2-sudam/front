import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../core/app_colors.dart';
import '../../widgets/primary_button.dart';

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

  final List<String> _samples = const [
    '안녕하세요. 어디가 불편하세요?',
    '잠시만 기다려 주세요.',
    '성함과 생년월일을 확인하겠습니다.',
  ];

  int _sampleIndex = 0;
  String _recognizedText = '수어 입력이 들어오면 여기에 한국어 결과가 표시됩니다.';
  String _generatedText = '한국어 안내 문장을 입력하면 여기에 수어 출력 준비 상태가 표시됩니다.';

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

  void _simulateRecognition() {
    setState(() {
      _recognizedText = _samples[_sampleIndex % _samples.length];
      _sampleIndex++;
    });
  }

  void _generateSign() {
    final text = _guideController.text.trim();
    setState(() {
      _generatedText = text.isEmpty ? '입력된 문장이 없습니다.' : text;
    });
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _mode == TranslateMode.signToText
                ? _SignToTextView(
              key: const ValueKey('signToText'),
              modeSwitcher: modeSwitcher,
              recognizedText: _recognizedText,
            )
                : _TextToSignView(
              key: const ValueKey('textToSign'),
              modeSwitcher: modeSwitcher,
              controller: _guideController,
              generatedText: _generatedText,
              onGenerate: _generateSign,
            ),
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
  });

  final Widget modeSwitcher;
  final String recognizedText;

  @override
  Widget build(BuildContext context) {
    final cameraWithOverlays = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          const Positioned.fill(
            child: LiveCameraView(),
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
// 🌟 한국어 -> 수어 화면 (아바타/입력)
// ----------------------------------------------------
class _TextToSignView extends StatelessWidget {
  const _TextToSignView({
    super.key,
    required this.modeSwitcher,
    required this.controller,
    required this.generatedText,
    required this.onGenerate,
  });

  final Widget modeSwitcher;
  final TextEditingController controller;
  final String generatedText;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final avatarWithOverlays = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  generatedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                  ),
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
              child: modeSwitcher,
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
                    controller: controller,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: '안내 문장을 입력해 주세요.',
                      hintStyle: TextStyle(color: AppColors.subText.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: PrimaryButton(
                    text: '변환',
                    onPressed: onGenerate,
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
// 🌟 실시간 카메라 위젯 (녹화 UI + 깜빡이는 REC 추가)
// ----------------------------------------------------
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({super.key});

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

// 💡 애니메이션 처리를 위해 TickerProviderStateMixin을 추가합니다.
class _LiveCameraViewState extends State<LiveCameraView> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isProcessing = false;
  List<Pose> _poses = [];
  Size? _imageSize;

  bool _isRecording = false;
  List<List<Pose>> _recordedSession = [];

  // 💡 'REC' 깜빡임 효과를 위한 컨트롤러
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _initCamera();

    // 💡 0.8초 주기로 깜빡이는 애니메이션 설정
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
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
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
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

      _controller!.startImageStream((CameraImage image) async {
        if (_isProcessing) return;
        _isProcessing = true;

        try {
          final inputImage = _inputImageFromCameraImage(image, frontCamera);
          if (inputImage != null) {
            final poses = await _poseDetector.processImage(inputImage);
            if (mounted) {
              setState(() {
                _poses = poses;
                _imageSize = Size(image.width.toDouble(), image.height.toDouble());
              });

              if (_isRecording) {
                _recordedSession.add(poses);
              }
            }
          }
        } catch (e) {
          debugPrint('관절 인식 오류: $e');
        } finally {
          _isProcessing = false;
        }
      });

    } catch (e) {
      setState(() => _errorMessage = '카메라 초기화 오류:\n$e');
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;

      if (_isRecording) {
        _recordedSession.clear();
        _blinkController.repeat(reverse: true); // 💡 녹화 시작 시 깜빡임 시작!
        debugPrint('🟢 수어 녹화 시작!');
      } else {
        _blinkController.stop(); // 💡 녹화 종료 시 깜빡임 정지
        _blinkController.value = 1.0; // 숨김 처리 초기화
        debugPrint('🔴 수어 녹화 종료! 총 ${_recordedSession.length} 프레임 수집됨.');
      }
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image, CameraDescription camera) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
        (Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888);

    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  @override
  void dispose() {
    _blinkController.dispose(); // 💡 메모리 누수 방지
    _poseDetector.close();
    _controller?.stopImageStream();
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

              if (_poses.isNotEmpty && _imageSize != null)
                CustomPaint(
                  painter: RealPosePainter(_poses, _imageSize!),
                ),

              // 💡 1. 녹화 중일 때 화면 전체에 붉은 테두리 효과
              if (_isRecording)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent.withOpacity(0.8), width: 6),
                  ),
                ),

              // 상단: 사람 인식 상태 표시 바
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _poses.isNotEmpty ? Colors.green.withOpacity(0.8) : Colors.redAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _poses.isNotEmpty ? '👀 사람 인식 됨' : '🤔 화상 밖으로 벗어났습니다.',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // 💡 2. 좌측 상단 깜빡이는 [🔴 REC] 표시
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

              // 하단: 녹화 시작/정지 버튼
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

// ----------------------------------------------------
// 🌟 눕는 뼈대 강제 기상! (수동 90도 회전 화가)
// ----------------------------------------------------
class RealPosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;

  RealPosePainter(this.poses, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final paintLine = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // AI 원본 사진의 가로/세로를 서로 바꾼 비율을 구합니다.
    final double scaleX = size.width / imageSize.height;
    final double scaleY = size.height / imageSize.width;

    for (final pose in poses) {
      Offset getPoint(PoseLandmark landmark) {
        // 💡 1. 왼쪽으로 90도 누운 뼈대를 시계방향으로 90도 돌려서 일으켜 세웁니다!
        double rotatedX = landmark.y;
        double rotatedY = landmark.x;

        // 💡 2. 화면 크기에 맞게 스케일링
        double x = rotatedX * scaleX;
        double y = rotatedY * scaleY;

        // 💡 3. 전면 카메라 거울 모드 (좌우 반전)
        // 🚨 만약 뼈대가 왼쪽/오른쪽 나랑 반대로(청개구리처럼) 움직이면 아래 줄 맨 앞에 // 를 붙여서 꺼주세요!
        x = size.width - x;

        return Offset(x, y);
      }

      // 점 찍기
      pose.landmarks.forEach((_, landmark) {
        if (landmark.likelihood > 0.5) {
          canvas.drawCircle(getPoint(landmark), 5.0, paintPoint);
        }
      });

      // 뼈대 선 긋기
      void drawBone(PoseLandmarkType type1, PoseLandmarkType type2) {
        final lm1 = pose.landmarks[type1];
        final lm2 = pose.landmarks[type2];
        if (lm1 != null && lm2 != null && lm1.likelihood > 0.5 && lm2.likelihood > 0.5) {
          canvas.drawLine(getPoint(lm1), getPoint(lm2), paintLine);
        }
      }

      // 얼굴
      drawBone(PoseLandmarkType.leftEar, PoseLandmarkType.leftEye);
      drawBone(PoseLandmarkType.leftEye, PoseLandmarkType.nose);
      drawBone(PoseLandmarkType.nose, PoseLandmarkType.rightEye);
      drawBone(PoseLandmarkType.rightEye, PoseLandmarkType.rightEar);
      // 어깨, 팔
      drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      drawBone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      drawBone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    }
  }

  @override
  bool shouldRepaint(covariant RealPosePainter oldDelegate) => true;
}