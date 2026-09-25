import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: -5.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(
        Duration(milliseconds: i * 160),
        () {
          if (mounted) {
            _controllers[i].repeat(reverse: true);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dotColor = theme.brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SizedBox(
      height: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) {
            return AnimatedBuilder(
              animation: _controllers[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    _animations[index].value,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < 2 ? 4.0 : 0.0,
                    ),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}