import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
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
                      // 상단 뒤로가기 버튼
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

                      // 메인 콘텐츠 영역 (키보드 대응을 위한 스크롤뷰 포함)
                      Center(
                        child: SingleChildScrollView(
                          child: wide
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 360,
                                child: _LoginBrandArea(),
                              ),
                              SizedBox(width: 88),
                              SizedBox(
                                width: 420,
                                child: _LoginForm(),
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

class _LoginForm extends StatelessWidget {
  const _LoginForm();

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
        // 💡 핵심 수정: 이메일 ➔ 아이디로 변경
        const TextField(
          decoration: InputDecoration(
            labelText: '아이디',
            hintText: '아이디 입력',
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호 입력',
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          text: '로그인하기',
          onPressed: () {
            // 시연용: 로그인 성공 시 홈화면으로 이동
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const HomePage(),
              ),
                  (route) => false,
            );
          },
        ),
      ],
    );
  }
}