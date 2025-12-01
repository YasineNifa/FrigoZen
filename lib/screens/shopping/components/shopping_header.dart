import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:provider/provider.dart';

class ShoppingHeader extends StatelessWidget implements PreferredSizeWidget {
  const ShoppingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<ShoppingViewModel>();
    final allChecked = vm.items.isNotEmpty && vm.items.every((item) => item.isChecked);

    return AppBar(
      title: Text(l10n.shoppingTitle),
      actions: [
        if (vm.items.isNotEmpty)
          IconButton(
            icon: Icon(
              allChecked ? Icons.deselect_outlined : Icons.select_all,
              color: Colors.black87,
            ),
            tooltip: allChecked ? "Tout décocher" : "Tout cocher",
            onPressed: () => vm.toggleSelectAll(),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
