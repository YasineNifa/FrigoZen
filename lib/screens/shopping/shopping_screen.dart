import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/components/input_field.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/screens/shopping/components/shopping_header.dart';
import 'package:frigo_zen/screens/shopping/components/shopping_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/theme/app_theme.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewModel();
    });
  }

  Future<void> _initViewModel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final householdId = await HouseholdRepository().getHouseholdIdForUser(userId);
      if (householdId != null && mounted) {
        context.read<ShoppingViewModel>().init(householdId);
        context.read<InventoryViewModel>().init(householdId);
      }
    }
  }

  void _addItem() async {
    final itemName = _textController.text.trim();
    if (itemName.isEmpty) return;

    final vm = context.read<ShoppingViewModel>();
    final l10n = AppLocalizations.of(context)!;

    final inventoryVM = context.read<InventoryViewModel>();

    FocusScope.of(context).unfocus();

    try {
      // 1. Resolve item name to get canonical data
      // We use a temporary loading state or just await (UI might freeze slightly but it's a network call)
      // Ideally we should show a loading indicator.
      // Since `_addItem` is async, we can show a loading indicator if we want.
      // But for now, let's just await.
      
      final resolvedItem = await vm.resolveItemName(itemName);
      
      if (resolvedItem != null) {
        final canonicalName = resolvedItem.canonicalName;
        final nameToCheck = resolvedItem.name;

        // 2. Check for duplicates in inventory using canonical name

        
        final existsInInventory = inventoryVM.items.any((item) {
            final match = item.canonicalName.toLowerCase() == canonicalName.toLowerCase() ||
                          item.name.toLowerCase() == nameToCheck.toLowerCase();
            return match;
        });
        
        if (existsInInventory) {
          if (!mounted) return;
          final shouldAdd = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Produit déjà en stock"),
              content: Text("Vous avez déjà '$nameToCheck' dans votre inventaire. Voulez-vous l'ajouter quand même à la liste de courses ?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Non"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Oui, ajouter"),
                ),
              ],
            ),
          );

          if (shouldAdd != true) {
            _textController.clear();
            return;
          }
        }
        
        // 3. Add the resolved item directly (optimization: we already resolved it)
        // But `addItemByName` resolves it again. 
        // We can call `vm.addItem(resolvedItem)` directly to save a call!
        await vm.addItem(resolvedItem);
      } else {
        // Fallback if resolution failed (shouldn't happen often as resolveItemName returns fallback)
        await vm.addItemByName(itemName);
      }

      _textController.clear();
      
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shoppingErrorGeneric(error.toString())),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<ShoppingViewModel>();
    final checkedCount = vm.items.where((i) => i.isChecked).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const ShoppingHeader(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomizedInputField(
              textController: _textController,
              isAdding: vm.isLoading, // Use VM loading state
              onAdd: _addItem,
            ),
          ),
          const Expanded(
            child: ShoppingListView(),
          ),
        ],
      ),
      floatingActionButton: checkedCount == 0
          ? null
          : FloatingActionButton.extended(
              icon: vm.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                vm.isLoading
                    ? l10n.shoppingAddingBtn
                    : l10n.shoppingMoveBtn(checkedCount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: vm.isLoading ? null : () async {
                try {
                  await vm.moveCheckedItemsToInventory();
                  if (!context.mounted) return;
                  
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Courses terminées !"),
                        content: Text(l10n.shoppingMovedSuccess(checkedCount)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Rester ici"),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              // Navigate to Inventory (index 1)
                              context.read<NavigationController>().setIndex(1);
                            },
                            child: const Text("Voir l'inventaire"),
                          ),
                        ],
                      ),
                    );

                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.shoppingMoveError(e.toString()))),
                    );
                  }
                }
              },
            ),
    );
  }
}

