import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/components/input_field.dart';
import 'package:frigo_zen/components/scan_tip_card.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/screens/shopping/components/shopping_header.dart';
import 'package:frigo_zen/screens/shopping/components/shopping_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/theme/app_theme.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';

import 'package:confetti/confetti.dart';

import 'package:frigo_zen/services/ocr_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _textController = TextEditingController();
  late ConfettiController _confettiController;
  bool _isLocalLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewModel();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
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

    // Set loading state manually since we are doing logic outside VM first
    setState(() {
      // We can't easily set VM loading state from here without a method.
      // But CustomizedInputField uses `vm.isLoading`.
      // We should probably add `setLoading(true)` to VM or handle it locally.
      // Since `CustomizedInputField` takes `isAdding`, we can pass a local state if we want,
      // OR we can use a local boolean `_isAdding` and pass `vm.isLoading || _isAdding`.
    });
    
    // Actually, let's use a local state variable `_isLocalLoading`
    // I need to add it to the state class first.
    // Wait, I can't add a variable in this replace block easily if it's far away.
    // I'll assume I can add it or I'll just use the VM's `addItemByName` which sets loading.
    // But `resolveItemName` does NOT set loading.
    
    // Plan:
    // 1. Add `bool _isLocalLoading = false;` to state.
    // 2. Wrap logic in try/finally setting this bool.
    // 3. Update `CustomizedInputField` to use `vm.isLoading || _isLocalLoading`.
    
    // Since I can't do all in one block if they are far apart, I will do it in steps.
    // This block is for `_addItem`. I will assume `_isLocalLoading` exists.
    
    setState(() {
      _isLocalLoading = true;
    });

    try {
      // 1. Resolve item name
      final languageCode = Localizations.localeOf(context).languageCode;
      final resolvedItem = await vm.resolveItemName(itemName, languageCode);
      
      if (!mounted) return;

      if (resolvedItem != null) {
        final canonicalName = resolvedItem.canonicalName;
        final nameToCheck = resolvedItem.name;

        // 2. Check for duplicates (ONLY FOR PRO USERS)
        final isPro = context.read<RevenueProvider>().isPro;
        bool existsInInventory = false;

        if (isPro) {
          existsInInventory = inventoryVM.items.any((item) {
              final match = item.canonicalName.toLowerCase() == canonicalName.toLowerCase() ||
                            item.name.toLowerCase() == nameToCheck.toLowerCase();
              return match;
          });
        }
        
        if (existsInInventory) {
          // Hide loading before dialog
          setState(() {
             _isLocalLoading = false;
          });

          final shouldAdd = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.shoppingItemAlreadyInStockTitle),
              content: Text(l10n.shoppingItemAlreadyInStockMessage(nameToCheck)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.shoppingDialogNo),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.shoppingDialogYesAdd),
                ),
              ],
            ),
          );

          if (shouldAdd != true) {
            _textController.clear();
            return;
          }
          
          // Show loading again if proceeding
          setState(() {
             _isLocalLoading = true;
          });
        }
        
        await vm.addItem(resolvedItem);
      } else {
        await vm.addItemByName(itemName, languageCode);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
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
      body: Stack(
        children: [
          Column(
            children: [
              CustomizedInputField(
                textController: _textController,
                isAdding: vm.isLoading || _isLocalLoading,
                onAdd: _addItem,
                showPremiumLock: !context.watch<RevenueProvider>().isPro,
                onPremiumLockTap: () {
                  PremiumGuard.checkPremiumStatus(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ScanTipCard(),
              ),
              const Expanded(
                child: ShoppingListView(),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
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
                final isPro = context.read<RevenueProvider>().isPro;

                if (isPro) {
                  final shouldScan = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.shoppingPrioritizeScanTitle),
                      content: Text(l10n.shoppingPrioritizeScanMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.shoppingPrioritizeManualBtn),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.shoppingPrioritizeScanBtn),
                        ),
                      ],
                    ),
                  );

                  if (shouldScan == true) {
                    if (!context.mounted) return;
                    // Use OcrService to scan receipt
                    // We need a parent context for OcrService, but here context is fine.
                    // OcrService().pickAndProcessReceipt(context, ImageSource.camera);
                    // Wait, OcrService might need to be instantiated or static?
                    // Checking ScanOptionsSheet usage: OcrService ocrService = OcrService();
                    final ocrService = OcrService();
                    // It seems pickAndProcessReceipt takes (BuildContext context, ImageSource source)
                    await ocrService.pickAndProcessReceipt(context, ImageSource.camera);
                    return;
                  }
                }

                try {
                  await vm.moveCheckedItemsToInventory(l10n.shoppingTitle);
                  if (!context.mounted) return;
                  
                  _confettiController.play();

                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.shoppingFinishedTitle,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.shoppingMovedSuccess(checkedCount),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.shoppingDialogStay),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              // Navigate to Inventory (index 1)
                              context.read<NavigationController>().setIndex(1);
                            },
                            child: Text(l10n.shoppingDialogViewInventory),
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

