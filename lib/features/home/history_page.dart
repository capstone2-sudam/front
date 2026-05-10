import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/soft_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 더미 데이터: 장갑 입력(SL_TO_KOR)인 경우 glove_name 추가
    final List<Map<String, dynamic>> historyLogs = [
      {
        'direction': 'KOR_TO_SL',
        'input_text': '안녕하세요, 만나서 반갑습니다.',
        'pose_file': '/poses/log_102.json',
        'time': '2026.04.05 14:20',
      },
      {
        'direction': 'SL_TO_KOR',
        'result_text': '배가 고파요 식당 어디인가요?',
        'time': '2026.04.05 12:05',
        'glove_name': '수담 글러브 R-01', // 🌟 우측 장갑 1번에서 입력됨
      },
      {
        'direction': 'KOR_TO_SL',
        'input_text': '감사합니다.',
        'pose_file': '/poses/log_100.json',
        'time': '2026.04.04 18:30',
      },
      {
        'direction': 'SL_TO_KOR',
        'result_text': '오늘 날씨가 정말 좋네요.',
        'time': '2026.04.04 15:10',
        'glove_name': '수담 글러브 L-02', // 🌟 좌측 장갑 2번에서 입력됨
      },
    ];

    return AppShell(
      title: '번역 내역',
      subtitle: '과거 진행된 번역 로그를 확인합니다.',
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: historyLogs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = historyLogs[index];
          final isKorToSl = log['direction'] == 'KOR_TO_SL';

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              // TODO: 상세 내역 보기 로직
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isKorToSl ? '아바타 재생 데이터를 불러옵니다.' : '상세 번역 텍스트를 확인합니다.')),
              );
            },
            child: SoftCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isKorToSl
                          ? AppColors.mint.withOpacity(0.2)
                          : AppColors.softBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isKorToSl ? Icons.record_voice_over_rounded : Icons.back_hand_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 💡 방향 표시와 장갑 태그를 나란히 배치
                        Row(
                          children: [
                            Text(
                              isKorToSl ? '한국어 ➔ 수어' : '수어 ➔ 한국어',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isKorToSl ? Colors.teal : Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 🌟 수어 입력일 때만 장갑 번호 태그 표시
                            if (!isKorToSl && log.containsKey('glove_name'))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.line.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '🧤 ${log['glove_name']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.subText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isKorToSl ? log['input_text'] : log['result_text'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['time'],
                          style: const TextStyle(fontSize: 13, color: AppColors.subText),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isKorToSl ? Icons.play_circle_fill_rounded : Icons.notes_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isKorToSl ? '재생' : '텍스트',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}