import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';
import 'glove_service.dart';

class GlovePage extends StatefulWidget {
  const GlovePage({super.key});

  @override
  State<GlovePage> createState() => _GlovePageState();
}

class _GlovePageState extends State<GlovePage> {
  final GloveService _gloveService = GloveService();
  // 💡 API에서 받아온 장갑 정보를 저장할 리스트 (Map 형태)
  List<dynamic> _gloves = [];
  int? _selectedIndex;
  bool _isLoading = true; // 로딩 상태 관리

  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGloves();
  }
  
  @override
  void dispose() {
    _deviceIdController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  // 백엔드에서 장갑 목록 불러오기
  Future<void> _fetchGloves() async {
    setState(() => _isLoading = true);
    final gloves = await _gloveService.getGloves();
    
    if (mounted) {
      setState(() {
        _gloves = gloves;
        _selectedIndex = null; // 초기화
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddDialog() async {
    _deviceIdController.clear();
    _nicknameController.clear();
    
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '장갑 등록',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _deviceIdController,
                autofocus: true,
                decoration: const InputDecoration(labelText: '장갑 기기 ID (필수)', hintText: '예: GL0001R'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '장갑 별명', hintText: '예: 오른손 수어 장갑'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기'),
            ),
            FilledButton(
              onPressed: () async {
                final deviceId = _deviceIdController.text.trim();
                final nickname = _nicknameController.text.trim();

                if (deviceId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장갑 기기 ID를 입력해주세요.')),
                  );
                  return;
                }

                Navigator.pop(dialogContext); // 모달 닫기
                
                final success = await _gloveService.addGlove(deviceId, nickname);

                if (success) {
                  await _fetchGloves(); // 리스트 갱신
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('장갑이 등록되었습니다.')),
                    );
                  }
                } else {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('장갑 등록에 실패했습니다.')),
                    );
                  }
                }
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeSelected() async {
    if (_selectedIndex == null) return;

    final selectedGlove = _gloves[_selectedIndex!];
    final gloveId = selectedGlove['gloveId'];
    final nickname = selectedGlove['nickname'] ?? gloveId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '장갑 삭제',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text('`$nickname` 장갑을 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    setState(() => _isLoading = true);

    final success = await _gloveService.deleteGlove(gloveId);

    if (success) {
      await _fetchGloves(); // 리스트 갱신
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('장갑이 삭제되었습니다.')),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('장갑 삭제에 실패했습니다.')),
        );
      }
    }
  }

  // 💡 상태 변경(토글) 처리 함수
  Future<void> _toggleGloveStatus(int index, bool isToggledOn) async {
    final glove = _gloves[index];
    final gloveId = glove['gloveId'];
    final newStatus = isToggledOn ? "ACTIVE" : "INACTIVE";
    final oldStatus = glove['status']; // API 실패 시 원상복구용

    // 1. 화면(UI)을 먼저 즉각적으로 바꿈 (Optimistic Update)
    setState(() {
      _gloves[index]['status'] = newStatus;
    });

    // 2. 백엔드 API 호출
    final success = await _gloveService.updateGloveStatus(gloveId, newStatus);

    // 3. 실패했다면 원상 복구 후 에러 메시지
    if (!success) {
      if (mounted) {
        setState(() {
          _gloves[index]['status'] = oldStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('장갑 상태 변경에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '장갑 관리',
      subtitle: '시스템에 필요한 장갑을 등록 및 삭제합니다.',
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
                          final selected = _selectedIndex == index;
                          final isActive = (glove['status'] == 'ACTIVE');
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // 💡 핵심 수정: 이미 선택된 항목을 다시 누르면 선택 해제(null), 아니면 새로 선택(index)
                                if (_selectedIndex == index) {
                                  _selectedIndex = null; 
                                } else {
                                  _selectedIndex = index;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.softBlue : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.line,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: selected ? Colors.white : AppColors.background,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.back_hand_rounded, 
                                        color: isActive ? AppColors.primary : Colors.grey.shade400),
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

                                  Switch(
                                    value: isActive, activeTrackColor: AppColors.primary,
                                    onChanged: (bool value) {
                                      _toggleGloveStatus(index, value);
                                    },
                                  ), 

                                  if (selected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: '등록',
                  icon: Icons.add_rounded,
                  onPressed: _openAddDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: '삭제',
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  onPressed: _selectedIndex == null ? null : _removeSelected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}