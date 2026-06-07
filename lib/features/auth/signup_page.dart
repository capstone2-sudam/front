import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/sudam_logo.dart';
import 'login_page.dart';
import 'auth_service.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
                                          child: const _SignUpBrandArea(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 460),
                                          child: const _SignUpForm(wide: true),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _SignUpBrandArea(isMobile: true),
                                    SizedBox(height: 28),
                                    _SignUpForm(wide: false),
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

class _SignUpBrandArea extends StatelessWidget {
  const _SignUpBrandArea({this.isMobile = false});

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

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({required this.wide});

  final bool wide;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();
    final pwConfirm = _pwConfirmController.text.trim();

    if (name.isEmpty || id.isEmpty || pw.isEmpty || pwConfirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
      return;
    }

    if (pw != pwConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.signup(name, id, pw);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었습니다! 수담에 오신 것을 환영합니다.')
        ),
      );
        // 회원가입 성공 시 로그인 페이지로 이동시키거나 홈으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입에 실패했습니다. (이미 존재하는 아이디일 수 있습니다.)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wide) {
      // 💻 가이드 화면 (데스크톱/태블릿용 가로 배치)
      return _buildFormLayout(isWide: true);
    }
    // 📱 모바일 화면 (세로 배치)
    return _buildFormLayout(isWide: false);
  }

  // 화면 넓이에 따라 구조를 다르게 반환하기 위한 내부 위젯 빌드 함수
  Widget _buildFormLayout({required bool isWide}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '회원가입',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 24),

        if (isWide)
          Row(
            children: [
              Expanded(
                child: _buildTextField('이름', '이름 입력', _nameController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('아이디', '아이디 입력', _idController)),
                ],
              )
            else ...[
              _buildTextField('이름', '이름 입력', _nameController),
              const SizedBox(height: 16),
              _buildTextField('아이디', '아이디 입력', _idController),
            ],

              const SizedBox(height: 16),
        
        if (isWide)
          Row(
            children: [
              Expanded(child: _buildTextField('비밀번호', '비밀번호 입력', _pwController, isPassword: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('비밀번호 확인', '비밀번호 재입력', _pwConfirmController, isPassword: true)),
            ],
          )
        else ...[
          _buildTextField('비밀번호', '비밀번호 입력', _pwController, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField('비밀번호 확인', '비밀번호 재입력', _pwConfirmController, isPassword: true),
        ],

        const SizedBox(height: 24),
        
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PrimaryButton(
                text: '계정 만들기',
                onPressed: _handleSignUp, // 💡 함수 연결
              ),
      ],
    );
  }

  // 중복되는 TextField 코드를 줄이기 위한 헬퍼 위젯
  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}