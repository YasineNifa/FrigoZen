import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frigo_zen/components/skeleton.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/services/household_service.dart';

class InventoryHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRecipePressed;

  const InventoryHeader({
    super.key,
    required this.onRecipePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: StreamBuilder<DocumentSnapshot?>(
        stream: HouseholdService().getCurrentHouseholdStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Skeleton(width: 150, height: 24);
          }
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return Text(data['name'] ?? l10n.inventoryTab);
          }
          return Text(l10n.inventoryTitle);
        },
      ),
      actions: [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
