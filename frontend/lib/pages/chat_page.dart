import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/chat/chat_message_bubble.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/chat_empty_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();

    if (text.isEmpty) return;

    _inputController.clear();

    final token = context.read<AuthProvider>().token;

    _scrollToBottom();

    await context.read<ChatProvider>().sendMessage(
      text,
      token: token,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final bubbleOther = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.catWarm;

    final chat = context.watch<ChatProvider>();

    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Asesor Virtual',
            subtitle: 'En línea 24/7',
            onBackPressed: canPop
                ? () => Navigator.pop(context)
                : null,
          ),


          Expanded(
            child: chat.messages.isEmpty
                ? ChatEmptyState(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount:
                        chat.messages.length + (chat.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chat.messages.length) {
                        return TypingIndicatorBubble(
                          bubbleColor: bubbleOther,
                        );
                      }

                      return ChatMessageBubble(
                        message: chat.messages[index],
                        bubbleOtherColor: bubbleOther,
                        textColor: textColor,
                      );
                    },
                  ),
          ),

          ChatInputBar(
            controller: _inputController,
            isSending: chat.isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}