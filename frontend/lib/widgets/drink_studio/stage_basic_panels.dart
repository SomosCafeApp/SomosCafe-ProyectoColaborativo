import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/studio_prefs.dart';
import '../../core/utils/money_format.dart';
import '../../providers/drink_studio_provider.dart';
import '../../animations/press_scale.dart';
import 'milk_badge.dart';
import 'option_card.dart';
import 'studio_colors.dart';

/// Tamaño: las onzas cambian alto, ancho y capacidad del vaso.
class SizePanel extends StatelessWidget {
  const SizePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final o = s.options!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final keys = o.sizes.keys.toList();
    return StagePanel(
      title: '¿De qué tamaño la quieres?',
      hint: 'Mira cómo crece o se encoge tu vaso.',
      child: Row(
        children: [
          for (var i = 0; i < keys.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                child: PressScale(
                  onTap: () {
                    StudioHaptics.select();
                    s.setSize(keys[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                    decoration: BoxDecoration(
                      color: s.size == keys[i] ? StudioColors.primary.withValues(alpha: dark ? 0.3 : 0.14) : StudioColors.soft(dark),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: s.size == keys[i] ? StudioColors.primary : Colors.transparent, width: 2),
                      boxShadow: s.size == keys[i] ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))] : null,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 46, child: Align(alignment: Alignment.bottomCenter, child: MiniCup(scale: keys.length < 2 ? 1 : 0.7 + 0.6 * i / (keys.length - 1)))),
                        const SizedBox(height: 6),
                        Text(
                          o.ouncesOf(keys[i]) != null ? '${o.ouncesOf(keys[i])} oz' : keys[i],
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: StudioColors.text(dark)),
                        ),
                        Text(keys[i], style: TextStyle(fontSize: 12, color: StudioColors.muted(dark))),
                        const SizedBox(height: 4),
                        Text(formatExtra(o.sizes[keys[i]]!), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: StudioColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Base: temperatura (con efectos de escarcha o calor) y shots de espresso.
class BasePanel extends StatelessWidget {
  const BasePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final o = s.options!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return StagePanel(
      title: 'Prepara la base',
      hint: s.isCoffee ? 'Elige la temperatura y vierte shots extra de espresso.' : 'Elige la temperatura de tu bebida.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final t in o.types)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: t == o.types.last ? 0 : 10),
                    child: PressScale(
                      onTap: () {
                        StudioHaptics.select();
                        s.setType(t);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: s.type == t ? StudioColors.primary.withValues(alpha: dark ? 0.3 : 0.14) : StudioColors.soft(dark),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: s.type == t ? StudioColors.primary : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(t == 'Frío' ? Icons.ac_unit_rounded : Icons.local_fire_department_rounded, size: 32, color: t == 'Frío' ? const Color(0xFF5FA8C8) : const Color(0xFFE8772E)),
                            const SizedBox(height: 4),
                            Text(t, style: TextStyle(fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
                            Text(t == 'Frío' ? 'Hielo y frescura' : 'Vapor y calor', style: TextStyle(fontSize: 11.5, color: StudioColors.muted(dark))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (s.isCoffee && o.maxExtraShots > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shots extra de espresso', style: TextStyle(fontWeight: FontWeight.w700, color: StudioColors.text(dark))),
                      Text('${formatCop(o.extraShotPrice)} cada uno · máx. ${o.maxExtraShots}', style: TextStyle(fontSize: 12, color: StudioColors.muted(dark))),
                    ],
                  ),
                ),
                RoundStepButton(icon: Icons.remove_rounded, onTap: s.shots > 0 ? () => s.changeShots(-1) : null),
                SizedBox(width: 34, child: Center(child: Text('${s.shots}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: StudioColors.text(dark))))),
                RoundStepButton(
                  icon: Icons.add_rounded,
                  onTap: s.shots < o.maxExtraShots
                      ? () {
                          StudioHaptics.light();
                          s.changeShots(1);
                        }
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Botón circular de + / − (mantener presionado repite la acción).
class RoundStepButton extends StatefulWidget {
  const RoundStepButton({super.key, required this.icon, this.onTap, this.repeat = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool repeat;

  @override
  State<RoundStepButton> createState() => _RoundStepButtonState();
}

class _RoundStepButtonState extends State<RoundStepButton> {
  Timer? _timer;

  void _start() {
    if (!widget.repeat || widget.onTap == null) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 90), (_) => widget.onTap?.call());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _stop(),
      onLongPressCancel: _stop,
      child: IconButton.filled(
        onPressed: widget.onTap,
        icon: Icon(widget.icon),
        style: IconButton.styleFrom(
          backgroundColor: enabled ? StudioColors.primary : StudioColors.latte.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

/// Leche: variedad (con ilustración breve) y cantidad ajustable.
class MilkPanel extends StatelessWidget {
  const MilkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final milks = s.options!.milks;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final label = s.milkLevel < 0.02
        ? 'Sin leche'
        : s.milkLevel < 0.3
            ? 'Un chorrito'
            : s.milkLevel < 0.65
                ? 'Cantidad media'
                : 'Bien cargada';
    return StagePanel(
      title: 'Elige y vierte la leche',
      hint: 'Toca una variedad y ajusta la cantidad. Mantén presionado + o − para moverla rápido.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final m in milks.entries)
                    PressScale(
                      onTap: () {
                        StudioHaptics.select();
                        s.setMilk(m.key);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: w,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: s.milk == m.key ? StudioColors.primary.withValues(alpha: dark ? 0.3 : 0.14) : StudioColors.soft(dark),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: s.milk == m.key ? StudioColors.primary : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          children: [
                            SizedBox(width: 40, height: 40, child: CustomPaint(painter: MilkIllustrationPainter(milkKindOf(m.key)))),
                            const SizedBox(height: 4),
                            Text(m.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                            Text(formatExtra(m.value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: StudioColors.primary)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              RoundStepButton(icon: Icons.remove_rounded, repeat: true, onTap: s.milkLevel > 0 ? () => s.changeMilk(-0.04) : null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(minHeight: 10, value: s.milkLevel / 0.92, color: StudioColors.primary, backgroundColor: StudioColors.soft(dark)),
                    ),
                    const SizedBox(height: 4),
                    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: StudioColors.muted(dark))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              RoundStepButton(icon: Icons.add_rounded, repeat: true, onTap: s.milkLevel < 0.92 ? () => s.changeMilk(0.04) : null),
            ],
          ),
        ],
      ),
    );
  }
}
