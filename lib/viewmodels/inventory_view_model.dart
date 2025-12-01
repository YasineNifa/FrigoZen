import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';

class InventoryViewModel extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  
  // State
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String _selectedLocation = "Tout";
  String _searchQuery = "";
  String? _householdId;
  StreamSubscription<List<InventoryItem>>? _inventorySubscription;

  // Getters
  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String get selectedLocation => _selectedLocation;
  String get searchQuery => _searchQuery;

  List<InventoryItem> get filteredItems {
    return _items.where((item) {
      final matchesLocation = _selectedLocation == "Tout" || item.location == _selectedLocation;
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.canonicalName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.cleanedName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLocation && matchesSearch;
    }).toList();
  }

  InventoryViewModel({InventoryRepository? inventoryRepository})
      : _inventoryRepository = inventoryRepository ?? InventoryRepository();

  void init(String householdId) {
    if (_householdId == householdId) return;
    
    _householdId = householdId;
    _isLoading = true;
    notifyListeners();

    _inventorySubscription?.cancel();
    _inventorySubscription = _inventoryRepository.getInventoryStream(householdId).listen(
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error fetching inventory: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    if (_householdId == null) return;
    await _inventoryRepository.addInventoryItem(_householdId!, item);
  }

  Future<void> updateItem(InventoryItem item) async {
    if (_householdId == null) return;
    await _inventoryRepository.updateInventoryItem(_householdId!, item);
  }

  Future<void> deleteItem(String itemId) async {
    if (_householdId == null) return;
    await _inventoryRepository.deleteInventoryItem(_householdId!, itemId);
  }
  
  bool doesItemExist(String canonicalName) {
    return _items.any((item) => item.canonicalName == canonicalName);
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }
}
