import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/locator.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;
  Map<String, double> _monthlySpending = {};
  double _totalSpending = 0;

  int _totalItems = 0;
  int _itemsWithPrice = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final historyService = locator<HistoryService>();
    final logs = await historyService.getSpendingHistory();

    final Map<String, double> spending = {};
    double total = 0;
    int itemsFound = logs.length;
    int priceCount = 0;

    for (var log in logs) {
      if (log.details != null && log.details!['price'] != null) {
        final price = (log.details!['price'] as num).toDouble();
        final dateKey = DateFormat('MM/yy').format(log.timestamp);
        
        spending.update(dateKey, (value) => value + price, ifAbsent: () => price);
        total += price;
        priceCount++;
      }
    }

    final sortedKeys = spending.keys.toList()..sort((a, b) {
      final partsA = a.split('/').map(int.parse).toList();
      final partsB = b.split('/').map(int.parse).toList();
      if (partsA[1] != partsB[1]) return partsA[1].compareTo(partsB[1]);
      return partsA[0].compareTo(partsB[0]);
    });

    final sortedMap = {for (var k in sortedKeys) k: spending[k]!};

    if (mounted) {
      setState(() {
        _monthlySpending = sortedMap;
        _totalSpending = total;
        _totalItems = itemsFound;
        _itemsWithPrice = priceCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyse des Dépenses"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _monthlySpending.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "Pas assez de données pour l'analyse.",
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Trouvé $_totalItems articles dans l'historique, dont $_itemsWithPrice avec un prix enregistré.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Note : Seuls les articles ajoutés APRÈS la mise à jour seront comptabilisés.",
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      Expanded(child: _buildChart()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Total 6 derniers mois", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              "${_totalSpending.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final values = _monthlySpending.values.toList();
    final keys = _monthlySpending.keys.toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
             getTooltipColor: (_) => Colors.blueGrey,
             getTooltipItem: (group, groupIndex, rod, rodIndex) {
               return BarTooltipItem(
                 "${rod.toY.toStringAsFixed(2)} €",
                 const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
               );
             },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    keys[index],
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(keys.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: Colors.green,
                width: 20,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
