import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/reviews_provider.dart';

class ReviewForm extends StatefulWidget {
  final int initialRating;
  final String initialComment;
  final bool isSubmitting;
  final String submitLabel;
  final Future<bool> Function(int rating, String comment) onSubmit;

  const ReviewForm({
    super.key,
    this.initialRating = 0,
    this.initialComment = '',
    required this.isSubmitting,
    this.submitLabel = 'Publicar Reseña',
    required this.onSubmit,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  late int _rating;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _rating = widget.initialRating;

    _controller = TextEditingController(
      text: widget.initialComment,
    );

    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  bool get _isCommentLengthValid {
    final length = _controller.text.trim().length;

    return length > 0 && length <= kReviewCommentMaxLength;
  }

  bool get _canSubmit {
    return _rating > 0 &&
        _isCommentLengthValid &&
        !widget.isSubmitting;
  }

  Future<void> _submitReview() async {
    if (!_canSubmit) return;

    final success = await widget.onSubmit(
      _rating,
      _controller.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _controller.clear();

      setState(() {
        _rating = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final inputBgColor = isDark
        ? AppColors.darkBackground
        : const Color(0xFFF9F6EE);

    final borderColor = isDark
        ? AppColors.darkSurfaceSubtle
        : const Color(0xFFEFE8D8);

    final buttonBgColor = AppColors.primary;

    final buttonTextColor = Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TU CALIFICACIÓN
          Text(
            'Tu calificación',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: List.generate(
              5,
              (index) {
                final starValue = index + 1;
                final isSelected = starValue <= _rating;

                return GestureDetector(
                  onTap: widget.isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _rating = starValue;
                          });
                        },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : subtitleColor.withValues(alpha: 0.4),
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // TU COMENTARIO
          Text(
            'Tu comentario',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: kReviewCommentMaxLength,
            enabled: !widget.isSubmitting,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText:
                  'Cuéntanos tu experiencia con este producto...',
              hintStyle: TextStyle(
                color: subtitleColor.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: inputBgColor,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BOTÓN DE ENVIAR
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submitReview : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBgColor,
                foregroundColor: buttonTextColor,
                disabledBackgroundColor:
                    buttonBgColor.withValues(alpha: 0.5),
                disabledForegroundColor:
                    buttonTextColor.withValues(alpha: 0.7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: buttonTextColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_outlined,
                          color: buttonTextColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.submitLabel,
                          style: TextStyle(
                            color: buttonTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}