import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueProvider with ChangeNotifier {
  static const String _proEntitlementId = 'frigo_zen Pro';

  CustomerInfo? _customerInfo;
  StreamSubscription? _authSubscription;
  StreamSubscription? _userDocSubscription;
  String? _currentRevenueCatId;

  bool get isPro {
    if (_customerInfo == null) return false;
    return _customerInfo!.entitlements.active[_proEntitlementId] != null;
  }

  CustomerInfo? get customerInfo => _customerInfo;

  Future<void> init() async {
    // 1. Listen to RevenueCat updates
    Purchases.addCustomerInfoUpdateListener((info) {
      _customerInfo = info;
      notifyListeners();
    });

    // 2. Initial fetch (anonymous or cached)
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      print("Error RevenueCat init: $e");
    }

    // 3. Listen to Firebase Auth to sync identity
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _handleLogout();
      } else {
        _handleLogin(user);
      }
    });
  }

  void _handleLogin(User user) {
    // We need to know the householdId to decide which ID to use for RevenueCat
    // So we listen to the user's document in Firestore
    _userDocSubscription?.cancel();
    _userDocSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final householdId = data?['householdId'] as String?;
        final revenueCatId = householdId ?? user.uid;
        
        _identifyRevenueCat(revenueCatId);
      }
    });
  }

  Future<void> _handleLogout() async {
    _userDocSubscription?.cancel();
    _currentRevenueCatId = null;
    _customerInfo = null;
    notifyListeners();

    try {
      if (!await Purchases.isAnonymous) {
        await Purchases.logOut();
      }
    } catch (e) {
      print("Error RevenueCat logout: $e");
    }
  }

  Future<void> _identifyRevenueCat(String id) async {
    if (_currentRevenueCatId == id) return;

    try {
      print("RevenueProvider: Logging in with ID: $id");
      _currentRevenueCatId = id;
      final result = await Purchases.logIn(id);
      _customerInfo = result.customerInfo;
      notifyListeners();
    } catch (e) {
      print("Error RevenueCat login: $e");
      _currentRevenueCatId = null; // Reset on failure to retry later if needed
    }
  }

  // --- Public Actions ---

  void setCustomerInfo(CustomerInfo? info) {
    _customerInfo = info;
    notifyListeners();
  }
  
  Future<void> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _customerInfo = info;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
