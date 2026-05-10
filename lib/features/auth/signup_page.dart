import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/sudam_logo.dart';
import '../home/home_page.dart';

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

                      // 메인 콘텐츠 (스크롤 가능하게 처리)
                      Center(
                        child: SingleChildScrollView(
                          child: wide
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 360,
                                child: _SignUpBrandArea(),
                              ),
                              SizedBox(width: 88),
                              SizedBox(
                                width: 460,
                                child: _SignUpForm(wide: true),
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

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    // 공통 로직: 회원가입 성공 시 처리
    void handleSignUp(BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었습니다! 수담에 오신 것을 환영합니다.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
            (route) => false,
      );
    }

    if (wide) {
      // 💻 가이드 화면 (데스크톱/태블릿용 가로 배치)
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '회원가입',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '이름 입력',
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '아이디', // 💡 이메일에서 아이디로 변경
                    hintText: '아이디 입력',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호 입력',
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    hintText: '비밀번호 재입력',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: '계정 만들기',
            onPressed: () => handleSignUp(context),
          ),
        ],
      );
    }

    // 📱 모바일 화면 (세로 배치)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '회원가입',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 24),
        const TextField(
          decoration: InputDecoration(
            labelText: '이름',
            hintText: '이름 입력',
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: '아이디', // 💡 이메일에서 아이디로 변경
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
        const SizedBox(height: 16),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            hintText: '비밀번호 재입력',
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: '계정 만들기',
          onPressed: () => handleSignUp(context),
        ),
      ],
    );
  }
}