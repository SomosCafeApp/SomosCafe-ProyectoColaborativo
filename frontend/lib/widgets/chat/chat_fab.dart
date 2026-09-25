import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../pages/chat_page.dart';


class ChatFab extends StatelessWidget {
  const ChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
      },
      child: const Icon(Icons.question_answer_outlined, color: Colors.white),
    );
  }
}
