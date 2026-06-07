// lib/features/account/account_page.dart

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/api_client.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import '../auth/start_page.dart';

// ... (기존 임포트 생략)

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? _profileData; // 프로필 데이터를 저장할 변수
  bool _isLoading = true; // 로딩 상태 초기값

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 화면이 켜질 때 서버에서 프로필 정보를 불러옵니다.
  }

  // 서버에서 프로필 정보를 가져오는 함수
  Future<void> _loadProfile() async {
    try {
      final profile = await ApiClient().getMyProfile();
      setState(() {
        _profileData = profile;
        _isLoading = false; // 로딩 완료
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('프로필 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 백엔드 날짜 형식(ISO)을 보기 좋게 포맷팅 (예: 2026-03-15T12:00:00 -> 2026.03.15)
    String formattedDate = '정보 없음';
    if (_profileData != null && _profileData!['createdAt'] != null) {
      final rawDate = _profileData!['createdAt'].toString();
      if (rawDate.length >= 10) {
        formattedDate = rawDate.substring(0, 10).replaceAll('-', '.');
      }
    }

    return AppShell(
      title: '계정',
      subtitle: '로그인된 회원 정보를 확인합니다.',
      // 💡 로딩 중일 때는 로딩 위젯을 보여주고, 완료되면 리스트뷰를 보여줍니다.
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                      
                      // 💡 3. 서버에서 받아온 값을 배치 (CamelModel 규격 반영)
                      _InfoLine(label: '이름', value: _profileData?['name'] ?? '정보 없음'),
                      const SizedBox(height: 10),
                      _InfoLine(label: 'ID', value: _profileData?['loginId'] ?? '정보 없음'),
                      const SizedBox(height: 10),
                      _InfoLine(label: '가입시기', value: formattedDate),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: 140,
                        child: SecondaryButton(
                          text: '로그아웃',
                          onPressed: () async {
                            // 💡 4. 로그아웃 API 연결
                            final success = await ApiClient().logout();
                            if (success && mounted) {
                              // 첫 시작 페이지로 이동하며 모든 화면 스택 초기화
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const StartPage()),
                                (route) => false,
                              );
                            }
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
                      onPressed: () async {
                        // 💡 5. 탈퇴 전 사용자에게 확인 모달창 띄우기 (UX 개선)
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('회원 탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text('정말로 탈퇴하시겠습니까?\n등록된 데이터와 장갑 정보가 모두 삭제됩니다.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        // 사용자가 탈퇴를 최종 동의했을 경우
                        if (confirm == true && mounted) {
                          final success = await ApiClient().deleteMyAccount();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('회원탈퇴가 완료되었습니다.')),
                            );
                            // 첫 화면으로 이동
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const StartPage()),
                              (route) => false,
                            );
                          }
                        }
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