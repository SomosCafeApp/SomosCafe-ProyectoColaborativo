import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money_format.dart';
import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';
import 'studio_panels.dart';

/// Bandeja de control inferior: pestañas de ingredientes, el panel de
/// la pestaña activa y el botón para terminar. Todo en la misma pantalla.
class StudioTray extends StatelessWidget {
  const StudioTray({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tabs = s.tabs;
    final active = tabs.contains(s.tab) ? s.tab : tabs.first;

    return Container(
      decoration: BoxDecoration(
        color: StudioColors.panel(dark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _Tab(stage: tabs[i], selected: tabs[i] == active, visited: s.visited.contains(tabs[i]), onTap: () => s.goTo(tabs[i])),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim), child: child),
                ),
                child: KeyedSubtree(key: ValueKey(active), child: buildStudioPanel(active, s)),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onFinish,
                  style: FilledButton.styleFrom(
                    backgroundColor: StudioColors.primary,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text('Terminar mi bebida · ${formatCop(s.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.stage, required this.selected, required this.visited, required this.onTap});
  final StudioStage stage;
  final bool selected;
  final bool visited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 74,
        decoration: BoxDecoration(
          color: selected ? StudioColors.primary : StudioColors.soft(dark),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(stage.icon, size: 22, color: selected ? Colors.white : StudioColors.primary),
                  const SizedBox(height: 3),
                  Text(stage.label, maxLines: 1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : StudioColors.text(dark))),
                ],
              ),
            ),
            if (visited && !selected)
              const Positioned(top: 6, right: 8, child: Icon(Icons.check_circle_rounded, size: 13, color: StudioColors.primary)),
          ],
        ),
      ),
    );
  }
}
