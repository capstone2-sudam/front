import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../account/account_page.dart';
import '../conversation/conversation_page.dart';
import '../glove/glove_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '홈',
      subtitle: '',
      showBack: false,
      trailing: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountPage()),
            );
          },
          icon: const Icon(
            Icons.person_outline_rounded,
            size: 34,
            color: AppColors.primary,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '환영합니다.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '필요한 작업을 선택하세요.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.subText,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _HomeActionCard(
                          title: '번역',
                          subtitle: '한국어 및 수어 번역 기능을 제공합니다.',
                          icon: Icons.translate_rounded,
                          accentColor: AppColors.mint,
                          buttonText: '시작하기',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ConversationPage()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _HomeActionCard(
                          title: '장갑 관리',
                          subtitle: '시스템 내 장갑 등록과 삭제를 관리합니다.',
                          icon: Icons.back_hand_rounded,
                          accentColor: AppColors.softBlue,
                          buttonText: '관리하기',
                          // 💡 이제 장갑 관리 카드가 우측 전체를 차지하므로 isSmall을 false로 설정하여 크게 보여줍니다.
                          isSmall: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GlovePage()),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMobileCard(
                        context,
                        title: '번역 시작',
                        icon: Icons.translate_rounded,
                        color: AppColors.mint,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationPage())),
                      ),
                      const SizedBox(height: 16),
                      _buildMobileCard(
                        context,
                        title: '장갑 관리',
                        icon: Icons.back_hand_rounded,
                        color: AppColors.softBlue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlovePage())),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SoftCard(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.buttonText,
    required this.onTap,
    this.isSmall = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String buttonText;
  final VoidCallback onTap;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: isSmall
          ? const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 24)
          : const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: isSmall ? 54 : 96,
            height: isSmall ? 54 : 96,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(isSmall ? 16 : 28),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: isSmall ? 28 : 48,
            ),
          ),
          SizedBox(height: isSmall ? 10 : 32),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 24 : 36,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: isSmall ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 15 : 18,
              color: AppColors.subText,
              height: 1.3,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 170,
            height: 52,
            child: PrimaryButton(
              text: buttonText,
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}