import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/services/household_service.dart';

class InventoryHeader extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final VoidCallback onRecipePressed;

  const InventoryHeader({
    super.key,
    required this.tabController,
    required this.onRecipePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: StreamBuilder<DocumentSnapshot?>(
        stream: HouseholdService().getCurrentHouseholdStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return Text(data['name'] ?? l10n.inventoryTab);
          }
          return Text(l10n.inventoryTitle);
        },
      ),
      actions: [
        IconButton(
          color: Colors.yellow[700],
          icon: const Icon(Icons.lightbulb),
          tooltip: l10n.suggestRecipeTooltip,
          onPressed: onRecipePressed,
        ),
      ],
      bottom: TabBar(
        controller: tabController,
        labelColor: Theme.of(context).primaryColor,
        tabs: [
          Tab(text: l10n.inventoryTabAll),
          Tab(text: l10n.inventoryTabFridge),
          Tab(text: l10n.inventoryTabPantry),
          Tab(text: l10n.inventoryTabFreezer),
        ],
        indicatorColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).disabledColor,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
