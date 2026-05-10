import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/auth/start_page.dart';

void main() {
  runApp(const SudamSudamApp());
}

class SudamSudamApp extends StatelessWidget {
  const SudamSudamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '수담수담',
      theme: AppTheme.light,
      home: const StartPage(),
    );
  }
}