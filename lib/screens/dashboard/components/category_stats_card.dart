import 'package:flutter/material.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class CategoryStatsCard extends StatelessWidget {
  const CategoryStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        final distribution = vm.categoryDistribution;
        if (distribution.isEmpty) return const SizedBox.shrink();

        final sortedEntries = distribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topCategories = sortedEntries.take(5).toList();
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
                AppLocalizations.of(context)!.statsTopCategories,
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
                    sections: topCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final percentage = (item.value / total * 100).toStringAsFixed(0);
                      return PieChartSectionData(
                        color: _getColor(index),
                        value: item.value.toDouble(),
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
                children: topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getColor(index),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "${item.key} (${item.value})",
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
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

  Color _getColor(int index) {
    const colors = [
      Color(0xFF4A90E2),
      Color(0xFF50E3C2),
      Color(0xFFF5A623),
      Color(0xFFD0021B),
      Color(0xFF9013FE),
    ];
    return colors[index % colors.length];
  }
}
