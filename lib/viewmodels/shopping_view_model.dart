import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';

class ShoppingViewModel extends ChangeNotifier {
  final ShoppingRepository _shoppingRepository;

  // State
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  String? _householdId;
  StreamSubscription<List<ShoppingItem>>? _shoppingSubscription;

  // Getters
  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;

  ShoppingViewModel({ShoppingRepository? shoppingRepository})
      : _shoppingRepository = shoppingRepository ?? ShoppingRepository();

  void init(String householdId) {
    if (_householdId == householdId) return;

    _householdId = householdId;
    _isLoading = true;
    notifyListeners();

    _shoppingSubscription?.cancel();
    _shoppingSubscription = _shoppingRepository.getShoppingListStream(householdId).listen(
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error fetching shopping list: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addItem(ShoppingItem item) async {
    if (_householdId == null) return;
    await _shoppingRepository.addShoppingItem(_householdId!, item);
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (_householdId == null) return;
    await _shoppingRepository.updateShoppingItem(_householdId!, item);
  }

  Future<void> deleteItem(String itemId) async {
    if (_householdId == null) return;
    await _shoppingRepository.deleteShoppingItem(_householdId!, itemId);
  }

  Future<void> toggleItemChecked(ShoppingItem item) async {
    if (_householdId == null) return;
    final updatedItem = item.copyWith(isChecked: !item.isChecked);
    await _shoppingRepository.updateShoppingItem(_householdId!, updatedItem);
  }

  @override
  void dispose() {
    _shoppingSubscription?.cancel();
    super.dispose();
  }
}
