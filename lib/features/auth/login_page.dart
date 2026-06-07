import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'auth_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/sudam_logo.dart';
import '../home/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 16 : 12,
                vertical: wide ? 12 : 8,
              ),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SoftCard(
                  padding: EdgeInsets.all(wide ? 32 : 24),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SingleChildScrollView(
                          child: wide
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 360),
                                          child: const _LoginBrandArea(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 420),
                                          child: const _LoginForm(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _LoginBrandArea(isMobile: true),
                                    SizedBox(height: 28),
                                    _LoginForm(),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginBrandArea extends StatelessWidget {
  const _LoginBrandArea({this.isMobile = false});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SudamLogo(size: isMobile ? 220 : 320),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  // 로그인 버튼을 눌렀을 때 실행될 함수
  Future<void> _handleLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.login(id, pw);

    if (!mounted) return; // 비동기 작업 후 context 사용 전 필수 체크
    setState(() => _isLoading = false); // 로딩 종료

    if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '로그인',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _idController,
          decoration: const InputDecoration(
            labelText: '아이디',
            hintText: '아이디 입력',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pwController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호 입력',
          ),
        ),
        const SizedBox(height: 22),
        // 💡 로딩 중이면 인디케이터 표시, 아니면 버튼 표시
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PrimaryButton(
                text: '로그인하기',
                onPressed: _handleLogin, // 💡 함수 연결
              ),
      ],
    );
  }
}