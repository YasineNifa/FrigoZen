import 'package:flutter/material.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';

class StorageStatsCard extends StatelessWidget {
  const StorageStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        final distribution = vm.locationDistribution;
        if (distribution.isEmpty) return const SizedBox.shrink();

        // Sort by count descending
        final sortedEntries = distribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
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
                "Répartition par Lieu",
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
                    sections: sortedEntries.map((entry) {
                      final location = entry.key;
                      final count = entry.value;
                      final percentage = (count / total * 100).toStringAsFixed(0);
                      return PieChartSectionData(
                        color: _getColorForLocation(location),
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
                children: sortedEntries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getColorForLocation(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${entry.key} (${entry.value})",
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

  Color _getColorForLocation(String location) {
    switch (location.toLowerCase()) {
      case 'frigo':
      case 'fridge':
        return Colors.blue;
      case 'congélateur':
      case 'congelateur':
      case 'freezer':
        return Colors.lightBlueAccent;
      case 'placard':
      case 'pantry':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
