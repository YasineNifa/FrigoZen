import 'package:flutter/material.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class HealthStatsCard extends StatelessWidget {
  const HealthStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        final distribution = vm.nutriscoreDistribution;
        if (distribution.isEmpty) return const SizedBox.shrink();

        final sortedKeys = distribution.keys.toList()..sort();
        final total = distribution.values.fold(0, (sum, count) => sum + count);

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.statsNutriScore,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sortedKeys.map((score) {
                      final count = distribution[score]!;
                      final percentage = (count / total * 100).toStringAsFixed(0);
                      return PieChartSectionData(
                        color: _getColorForNutriScore(score),
                        value: count.toDouble(),
                        title: '$percentage%',
                        radius: 40,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: sortedKeys.map((score) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getColorForNutriScore(score),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${AppLocalizations.of(context)!.statsScoreLabel(score)} (${distribution[score]})",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForNutriScore(String score) {
    switch (score) {
      case 'A':
        return const Color(0xFF038141);
      case 'B':
        return const Color(0xFF85BB2F);
      case 'C':
        return const Color(0xFFFECB02);
      case 'D':
        return const Color(0xFFEE8100);
      case 'E':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }
}
