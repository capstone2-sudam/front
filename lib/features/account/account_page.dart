import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../auth/start_page.dart';

// ... (기존 임포트 생략)

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '계정',
      subtitle: '로그인된 회원 정보를 확인합니다.',
      child: ListView(
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 계정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 14),
                // 💡 요청하신 세 가지만 딱 배치!
                const _InfoLine(label: '이름', value: '수담수담'),
                const SizedBox(height: 10),
                const _InfoLine(label: 'ID', value: 'sudam_user'),
                const SizedBox(height: 10),
                const _InfoLine(label: '가입시기', value: '2026.03.15'),
                const SizedBox(height: 20),

                SizedBox(
                  width: 140,
                  child: SecondaryButton(
                    text: '로그아웃',
                    onPressed: () {
                      // ... (로그아웃 로직)
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 회원탈퇴 버튼 영역
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 120,
              child: PrimaryButton(
                text: '회원탈퇴',
                danger: true,
                onPressed: () {
                  // ... (회원탈퇴 로직)
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70, // '가입시기' 네 글자 기준으로 넉넉하게 설정
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.subText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}