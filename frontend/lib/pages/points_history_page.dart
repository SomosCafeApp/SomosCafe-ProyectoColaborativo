import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/points_model.dart';
import '../providers/points_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/rewards/points_history_tile.dart';
import '../widgets/rewards/points_summary_card.dart';

import '../animations/animations.dart';
enum _Filter { all, earned, spent }

/// Historial de puntos: compras que sumaron, cupones canjeados, bonos y
/// ajustes. Se abre desde Recompensas.
class PointsHistoryPage extends StatefulWidget {
  const PointsHistoryPage({super.key});

  @override
  State<PointsHistoryPage> createState() => _PointsHistoryPageState();
}

class _PointsHistoryPageState extends State<PointsHistoryPage> {
  _Filter _filter = _Filter.all;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final points = context.read<PointsProvider>();
    await Future.wait([points.fetchBalance(), points.fetchHistory()]);
    if (mounted) setState(() => _loading = false);
  }

  List<PointHistoryEntry> _visible(List<PointHistoryEntry> all) {
    switch (_filter) {
      case _Filter.earned:
        return all.where((e) => e.amount > 0).toList();
      case _Filter.spent:
        return all.where((e) => e.amount < 0).toList();
      case _Filter.all:
        return all;
    }
  }

  Widget _chip(String label, _Filter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: selected ? Colors.white : null,
      ),
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final points = context.watch<PointsProvider>();
    final history = points.history;
    final visible = _visible(history);

    final earned = history.where((e) => e.amount > 0).fold<int>(0, (sum, e) => sum + e.amount);
    final spent = history.where((e) => e.amount < 0).fold<int>(0, (sum, e) => sum + e.amount.abs());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Historial de puntos',
            subtitle: 'Lo que has ganado y canjeado',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(20),
                children: [
                  PointsSummaryCard(balance: points.balance, earned: earned, spent: spent),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip('Todos', _Filter.all),
                      _chip('Ganados', _Filter.earned),
                      _chip('Canjeados', _Filter.spent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loading && history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CoffeeCupLoader()),
                    )
                  else if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          history.isEmpty ? 'Aún no tienes movimientos de puntos.' : 'No hay movimientos en esta categoría.',
                          style: TextStyle(color: subtitleColor, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    for (final entry in visible) PointsHistoryTile(entry: entry),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
