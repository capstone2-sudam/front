import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../glove/glove_service.dart'; // 장갑 제어용
import '../calibration/calibration_page.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';


class GloveSelectionPage extends StatefulWidget {
  const GloveSelectionPage({super.key});

  @override
  State<GloveSelectionPage> createState() => _GloveSelectionPageState();
}

class _GloveSelectionPageState extends State<GloveSelectionPage> {
  final GloveService _gloveService = GloveService();
  List<dynamic> _gloves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGloves();
  }

  Future<void> _fetchGloves() async {
    final gloves = await _gloveService.getGloves();
    final activeGloves = gloves.where((glove) => glove['status'] == 'ACTIVE').toList();
    if (mounted) {
      setState(() { 
        _gloves = activeGloves; 
        _isLoading = false; });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '장갑 선택',
      subtitle: '영점 조절을 수행할 장갑을 선택하세요.',
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _gloves.isEmpty
                    ? SoftCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.softBlue,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.back_hand_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              '등록된 장갑이 없습니다.',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _gloves.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final glove = _gloves[index];
                          final isActive = glove['status'] == 'ACTIVE';
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CalibrationPage(gloveId: glove['gloveId']),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface, // 선택 배경색 대신 기본 표면색 유지
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white ,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.back_hand_rounded, 
                                      color: isActive ? AppColors.primary : Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          glove['nickname'] ?? '이름 없음',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${glove['gloveId']} | 방향: ${glove['direction']}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.subText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.subText),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}