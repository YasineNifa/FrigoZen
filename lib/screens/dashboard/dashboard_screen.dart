import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_summary_card.dart';
import 'package:frigo_zen/screens/inventory/components/scan_options_sheet.dart';
import 'package:frigo_zen/screens/dashboard/components/health_stats_card.dart';
import 'package:frigo_zen/screens/dashboard/components/category_stats_card.dart';
import 'package:frigo_zen/screens/dashboard/components/storage_stats_card.dart';
import 'package:frigo_zen/screens/dashboard/components/expiring_soon_carousel.dart';
import 'package:frigo_zen/screens/dashboard/components/store_stats_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/screens/dashboard/components/premium_stats_wrapper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewModel();
    });
  }

  Future<void> _initViewModel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final householdId = await HouseholdRepository().getHouseholdIdForUser(userId);
      if (householdId != null && mounted) {
        context.read<InventoryViewModel>().init(householdId);
      }
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ScanOptionsSheet(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InventorySummaryCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Actions Rapides",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.add_circle_outline,
                      label: "Ajouter un produit",
                      color: Theme.of(context).primaryColor,
                      onTap: () => _showImageSourceDialog(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ExpiringSoonCarousel(),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(
                      child: PremiumStatsWrapper(child: StorageStatsCard()),
                    ),
                    Expanded(
                      child: PremiumStatsWrapper(child: HealthStatsCard()),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(
                      child: PremiumStatsWrapper(child: CategoryStatsCard()),
                    ),
                    Expanded(
                      child: PremiumStatsWrapper(child: StoreStatsCard()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
