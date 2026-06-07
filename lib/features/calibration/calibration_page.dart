import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../glove/glove_service.dart'; // 장갑 제어용

enum CalibrationStep { intro, transitionClose, close, transitionOpen, open, done }

class CalibrationPage extends StatefulWidget {
  final String gloveId;
  const CalibrationPage({super.key, required this.gloveId});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  final GloveService _gloveService = GloveService();
  CalibrationStep _step = CalibrationStep.intro;
  int _timerValue = 2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _runWorkflow();
  }

  Future<void> _runWorkflow() async {
    // 1. 안내 2초
    await _startTimer(2, CalibrationStep.intro);
    
    // 2. 💡 [추가됨] 주먹 쥐기 전 1초 간격 (미리 FOLD 명령 전송)
    setState(() {
      _step = CalibrationStep.transitionClose;
      _timerValue = 1; 
    });
    await _gloveService.sendGloveCommand(widget.gloveId, "CALIBRATION_FOLD");
    await Future.delayed(const Duration(seconds: 1));

    // 3. 주먹 쥐기(FOLD) 3초 카운트
    await _startTimer(3, CalibrationStep.close);

    // 4. 손 펴기 전 1초 간격 (미리 UNFOLD 명령 전송)
    setState(() {
      _step = CalibrationStep.transitionOpen;
      _timerValue = 1; 
    });
    await _gloveService.sendGloveCommand(widget.gloveId, "CALIBRATION_UNFOLD");
    await Future.delayed(const Duration(seconds: 1));
    
    // 5. 손 펴기(UNFOLD) 3초 카운트
    await _startTimer(3, CalibrationStep.open);
    
    // 6. 완료
    if (mounted) {
      setState(() => _step = CalibrationStep.done);
    }
  }

  Future<void> _startTimer(int seconds, CalibrationStep nextStep) async {
    // 1. 상태 및 초기값 즉시 설정
    setState(() {
      _step = nextStep;
      _timerValue = seconds; // 예를 들어 3으로 시작
    });
    
    // 2. 3, 2, 1 카운트다운 로직
    for (int i = seconds - 1; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1)); // 1초 대기
      
      if (!mounted) return;
      
      if (i > 0) {
        setState(() => _timerValue = i); // 다음 숫자로 즉시 업데이트
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: _step == CalibrationStep.done, // 완료 전에는 뒤로가기 금지
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        // 뒤로가기 시도 시 경고창
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('영점 조절 중에는 취소할 수 없습니다.')),
        );
      }
    },
    child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('장갑 ID: ${widget.gloveId}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            _buildDisplay(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDisplay() {
    // 1. 완료 상태 UI
    if (_step == CalibrationStep.done) {
      return Column(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 100),
        const SizedBox(height: 16),
        const Text(
          "영점 조절 완료!", 
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text)
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "완료", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ),
        )
      ]);
    }

    // 2. 진행 상태별 텍스트 및 디자인 분기
    String instructionText = "";
    Color instructionColor = AppColors.text;
    double fontSize = 24.0;

    // 💡 스위치문을 업데이트하여 1초 준비 시간부터 해당 동작 텍스트가 뜨게 합니다.
    switch (_step) {
      case CalibrationStep.intro:
        instructionText = "영점 조절을 시작합니다.\n화면의 지시를 따라주세요.";
        fontSize = 22.0;
        break;
      case CalibrationStep.transitionClose: // 💡 주먹 쥐기 1초 전부터
      case CalibrationStep.close:           // 주먹 쥐기 3초 동안
        instructionText = "✊ 주먹을 쥐어주세요!";
        instructionColor = Colors.orange;
        fontSize = 28.0;
        break;
      case CalibrationStep.transitionOpen:  // 💡 손 펴기 1초 전부터
      case CalibrationStep.open:            // 손 펴기 3초 동안
        instructionText = "🖐️ 손가락을 편하게 펴주세요!";
        instructionColor = Colors.blue;
        fontSize = 28.0;
        break;
      default:
        break;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: instructionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: instructionColor.withOpacity(0.5), width: 2),
          ),
          child: Text(
            instructionText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: instructionColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 60),
        
        Text(
          "$_timerValue",
          style: TextStyle(
            fontSize: 120, 
            fontWeight: FontWeight.w900,
            // 💡 두 트랜지션 상태 중 하나라도 해당하면 회색으로 표시
            color: (_step == CalibrationStep.transitionClose || _step == CalibrationStep.transitionOpen) 
                ? Colors.grey.shade400 
                : AppColors.primary,
            height: 1.0,
          ),
        )
      ],
    );
  }
}