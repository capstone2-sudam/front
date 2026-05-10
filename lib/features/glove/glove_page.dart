import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/soft_card.dart';

class GlovePage extends StatefulWidget {
  const GlovePage({super.key});

  @override
  State<GlovePage> createState() => _GlovePageState();
}

class _GlovePageState extends State<GlovePage> {
  final List<String> _gloves = [];
  int? _selectedIndex;

  Future<void> _openAddDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '장갑 등록',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '장갑 이름',
              hintText: '예: 외래 1번 장갑',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                setState(() {
                  _gloves.add(name);
                  _selectedIndex = _gloves.length - 1;
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('장갑이 등록되었습니다.'),
                  ),
                );
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _removeSelected() async {
    if (_selectedIndex == null) return;

    final selectedName = _gloves[_selectedIndex!];

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
          content: Text('`$selectedName` 장갑을 삭제할까요?'),
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

    setState(() {
      _gloves.removeAt(_selectedIndex!);
      _selectedIndex = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('장갑이 삭제되었습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '장갑 관리',
      subtitle: '시스템에 필요한 장갑을 등록 및 삭제합니다.',
      child: Column(
        children: [
          Expanded(
            child: _gloves.isEmpty
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
                : ListView.separated(
              itemCount: _gloves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final selected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.softBlue
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.back_hand_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _gloves[index],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          ),
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