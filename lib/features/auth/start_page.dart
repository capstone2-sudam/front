import 'package:flutter/material.dart';

import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/sudam_logo.dart';
import 'login_page.dart';
import 'signup_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

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
                vertical: wide ? 16 : 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SoftCard(
                  padding: EdgeInsets.all(wide ? 32 : 24),
                  child: wide
                      ? Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 320,
                            ),
                            child: const _BrandArea(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 200),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 420,
                            ),
                            child: const _ActionPanel(),
                          ),
                        ),
                      ),
                    ],
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BrandArea(),
                      SizedBox(height: 28),
                      _ActionPanel(),
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

class _BrandArea extends StatelessWidget {
  const _BrandArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SudamLogo(size: 320),
        SizedBox(height: 1),
        Text(
          '손과 말이 이어지는 순간',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2846A6),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '양방향 의사소통 시스템',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7E8898),
          ),
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          text: '로그인',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 420,
          height: 60,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFEAF3FF), // 버튼 배경
              foregroundColor: const Color(0xFF2846A6), // 글자색
              side: const BorderSide(
                color: Color(0xFFD4E2FF), // 테두리색
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignUpPage(),
                ),
              );
            },
            child: const Text('회원가입'),
          ),
        ),
      ],
    );
  }
}