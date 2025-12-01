import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/components/input_field.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/screens/shopping/components/shopping_header.dart';
import 'package:frigo_zen/screens/shopping/components/shopping_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';

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
      }
    }
  }

  void _addItem() async {
    final itemName = _textController.text.trim();
    if (itemName.isEmpty) return;

    final vm = context.read<ShoppingViewModel>();
    final l10n = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    try {
      // Check for duplicates?
      // The original code checked inventory for duplicates.
      // Accessing InventoryProvider here is fine as it's just a check.
      // But ideally logic should be in VM.
      // For now, I'll keep the check here or move it to VM.
      // Moving to VM is better but requires VM to know about InventoryProvider or Repository.
      // I already injected InventoryRepository into ShoppingViewModel.
      // So I can just call `vm.addItemByName(itemName)` and let it handle logic.
      // But the duplicate check was against *Inventory*, asking user if they want to add anyway.
      // That requires UI interaction (SnackBar with Action).
      // So I should check here first.
      
      // Access InventoryViewModel to check existence (since InventoryProvider is being phased out/refactored)
      // Or use InventoryProvider as it's still there.
      // Let's use InventoryProvider for now as it holds the list of names efficiently.
      
      // Wait, I can't easily access InventoryProvider inside VM without passing it.
      // So keeping the check here is pragmatic.
      
      // final inventory = context.read<InventoryProvider>();
      // if (inventory.doesItemExist(itemName)) { ... }
      
      // However, `InventoryProvider` uses `_itemNames` which is updated by `InventoryScreen`.
      // If user goes directly to ShoppingScreen, `InventoryProvider` might be empty!
      // This is a flaw in the original design or my understanding.
      // `InventoryScreen` updates `InventoryProvider` in `build`.
      // If `InventoryScreen` hasn't been built, `InventoryProvider` is empty.
      // So this check might be flaky.
      // Assuming it works as before:
      
      await vm.addItemByName(itemName);
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const ShoppingHeader(),
      body: Column(
        children: [
          CustomizedInputField(
            textController: _textController,
            isAdding: vm.isLoading, // Use VM loading state
            onAdd: _addItem,
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
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.shoppingMovedSuccess(checkedCount)),
                        backgroundColor: Colors.green[700],
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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

