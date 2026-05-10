import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class SudamLogo extends StatelessWidget {
  const SudamLogo({
    super.key,
    this.size = 260,
    this.showWordMark = true,
  });

  final double size;
  final bool showWordMark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/img.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.25),
                  border: Border.all(color: AppColors.line),
                ),
                child: Icon(
                  Icons.sign_language_rounded,
                  size: size * 0.8,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}