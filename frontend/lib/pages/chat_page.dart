import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../animations/animations.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/chat_provider.dart';
import '../services/voice_service.dart';
import '../widgets/chat/chat_empty_state.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/chat_message_bubble.dart';
import '../widgets/chat/chat_quick_replies.dart';
import '../widgets/common/styled_confirm_dialog.dart';
import '../widgets/common/user_avatar.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import 'cart_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceService _voice = VoiceService();

  late final ChatProvider _chat;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _chat = context.read<ChatProvider>();
    // Cuando el chat agrega o vacía el carrito, se recarga el real.
    _chat.onCartChanged = () {
      if (mounted) context.read<CartProvider>().fetchCart();
    };
    _chat.addListener(_onChatChanged);
    _voice.addListener(_onVoiceChanged);
  }

  @override
  void dispose() {
    _chat.removeListener(_onChatChanged);
    _chat.onCartChanged = null;
    _voice.removeListener(_onVoiceChanged);
    _voice.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Lee en voz alta la respuesta nueva si el cliente activó la lectura automática.
  void _onChatChanged() {
    final messages = _chat.messages;
    if (messages.length > _lastCount && messages.isNotEmpty) {
      final last = messages.last;
      if (!last.isUser && !last.isError && _voice.autoRead) {
        _voice.speak(last.content);
      }
    }
    _lastCount = messages.length;
    _scrollToBottom();
  }

  void _onVoiceChanged() {
    if (!mounted) return;
    final error = _voice.errorMessage;
    if (error != null) {
      _voice.clearError();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
    setState(() {});
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

  String? get _token => context.read<AuthProvider>().token;

  Future<void> _send([String? override]) async {
    final text = (override ?? _inputController.text).trim();
    if (text.isEmpty) return;
    if (_voice.isListening) await _voice.cancelListening();
    _inputController.clear();
    await _chat.sendMessage(text, token: _token);
  }

  Future<void> _toggleMic() async {
    if (_voice.isListening) {
      await _voice.stopListening();
      return;
    }
    await _voice.startListening(
      onText: (text) {
        // Se escribe en la caja: el cliente puede corregirlo antes de enviar.
        _inputController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    );
  }

  Future<void> _selectProduct(Product product) =>
      _chat.sendMessage('Elegir ${product.name}', token: _token, selectProductId: product.id);

  void _openCart() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage()));
  }

  Future<void> _newConversation() async {
    final ok = await showStyledConfirmDialog(
      context,
      icon: Icons.add_comment_outlined,
      destructive: false,
      title: '¿Nueva conversación?',
      message: 'Se limpiará el chat actual. Tu carrito no se modifica.',
      confirmLabel: 'Empezar',
    );
    if (!ok || !mounted) return;
    await _voice.stopSpeaking();
    await _chat.startNewConversation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bubbleOther = isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm;

    final chat = context.watch<ChatProvider>();
    final user = context.watch<AuthProvider>().user;
    final canPop = Navigator.canPop(context);

    final userAvatar = user == null
        ? null
        : UserAvatar(
            imageUrl: user.profileImage,
            avatarPreset: user.avatarPreset,
            initials: UserAvatar.initialsFor(user.name, user.lastName),
            size: 28,
            fontSize: 11,
          );

    final messages = chat.messages;
    final lastIndex = messages.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Asesor Virtual',
            subtitle: 'En línea 24/7',
            onBackPressed: canPop ? () => Navigator.pop(context) : null,
          ),
          // Controles del chat: leer respuestas en voz alta y nueva conversación.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
              children: [
                FilterChip(
                  avatar: Icon(
                    _voice.autoRead ? Icons.volume_up_rounded : Icons.volume_off_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text('Leer respuestas'),
                  selected: _voice.autoRead,
                  onSelected: (v) {
                    setState(() => _voice.autoRead = v);
                    if (!v) _voice.stopSpeaking();
                  },
                ),
                const Spacer(),
                if (messages.isNotEmpty)
                  TextButton.icon(
                    onPressed: chat.isSending ? null : _newConversation,
                    icon: const Icon(Icons.add_comment_outlined, size: 18),
                    label: const Text('Nueva'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: chat.isLoadingHistory
                ? const Center(child: CoffeeCupLoader())
                : messages.isEmpty
                    ? ChatEmptyState(textColor: textColor, subtitleColor: subtitleColor)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        itemCount: messages.length + (chat.isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return TypingIndicatorBubble(bubbleColor: bubbleOther);
                          }

                          final message = messages[index];
                          return ChatMessageBubble(
                            message: message,
                            bubbleOtherColor: bubbleOther,
                            textColor: textColor,
                            userAvatar: userAvatar,
                            isLast: index == lastIndex,
                            busy: chat.isSending,
                            onQuickReply: _send,
                            onSelectProduct: _selectProduct,
                            onConfirm: () => chat.answerPending(accept: true, token: _token),
                            onCancel: () => chat.answerPending(accept: false, token: _token),
                            onRetry: () => chat.retry(token: _token),
                            onOpenCart: _openCart,
                            onSpeak: () => _voice.isSpeaking ? _voice.stopSpeaking() : _voice.speak(message.content),
                            isSpeaking: _voice.isSpeaking,
                          );
                        },
                      ),
          ),
          // Accesos rápidos solo al empezar; luego mandan los atajos de cada respuesta.
          if (!chat.isSending && !chat.isLoadingHistory && messages.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ChatQuickReplies(onPick: _send),
            ),
          ChatInputBar(
            controller: _inputController,
            isSending: chat.isSending,
            onSend: _send,
            voiceState: _voice.state,
            onMic: _toggleMic,
            onCancelVoice: () {
              _voice.cancelListening();
              _inputController.clear();
            },
          ),
        ],
      ),
    );
  }
}
