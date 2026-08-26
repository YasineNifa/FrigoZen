import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/services/trial_calculator.dart';

class RevenueProvider with ChangeNotifier {
  static const String _proEntitlementId = 'frigo Pro';
  static const String _prodEntitlementId = 'frigo_zen Pro';

  /// Trial duration in days. Override at build time for QA with
  /// `--dart-define=TRIAL_DAYS=0` (immediate expiry) or a small value.
  static const int trialDays = int.fromEnvironment('TRIAL_DAYS', defaultValue: 15);

  /// Debug-only override to preview trial UI without a real purchase.
  /// `true` forces an active trial, `false` forces an expired trial,
  /// `null` (default) uses the real account-bound trial date.
  static bool? debugTrialOverride;

  /// Debug-only switch to simulate a non-Pro user (e.g. trial expired and
  /// not subscribed). When `true`, `isPro` returns false even in debug builds,
  /// so the paywalls/locked features can be exercised locally.
  static bool? debugForceNonPro;

  CustomerInfo? _customerInfo;
  StreamSubscription? _authSubscription;
  StreamSubscription? _userDocSubscription;
  String? _currentRevenueCatId;
  DateTime? _trialStartDate;

  /// True only when the user has a real (RevenueCat) active subscription,
  /// excluding the free trial period.
  bool get isSubscribed {
    if (_customerInfo == null) return false;
    final active = _customerInfo!.entitlements.active;
    return active[_proEntitlementId] != null ||
        active[_prodEntitlementId] != null;
  }

  bool get isPro {
    // Debug-only lever: simulate a non-Pro user locally. Inert in release.
    if (!kReleaseMode && debugForceNonPro == true) return false;
    if (!kReleaseMode) return true;
    if (isInTrial) return true;
    return isSubscribed;
  }

  DateTime? get trialEndDate {
    // Debug-only lever: simulate active/expired trial. Inert in release.
    if (!kReleaseMode && debugTrialOverride == true) {
      return DateTime.now().add(const Duration(days: trialDays));
    }
    if (!kReleaseMode && debugTrialOverride == false) {
      return DateTime.now().subtract(const Duration(days: 1));
    }
    return TrialCalculator.endDate(_trialStartDate, trialDays);
  }

  bool get isInTrial => TrialCalculator.isInTrial(trialEndDate);

  bool get isTrialExpired => TrialCalculator.isExpired(trialEndDate);

  int get trialDaysRemaining => TrialCalculator.daysRemaining(trialEndDate);

  CustomerInfo? get customerInfo => _customerInfo;

  Future<void> init() async {
    // 1. Listen to RevenueCat updates
    Purchases.addCustomerInfoUpdateListener((info) {
      _customerInfo = info;
      notifyListeners();
      _syncPremiumStatusToFirestore();
    });

    // 2. Initial fetch (anonymous or cached)
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
      _syncPremiumStatusToFirestore();
    } catch (e) {
      debugPrint("Error RevenueCat init: $e");
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
            _ensureTrialStartDate(user.uid, data);
          }
        });
  }

  /// Records the trial start date on first login and keeps it for the account
  /// lifetime (preserved across reinstalls). A missing date means "not started".
  Future<void> _ensureTrialStartDate(String uid, Map<String, dynamic>? data) async {
    final raw = data?['trialStartDate'];
    if (raw is Timestamp) {
      _trialStartDate = raw.toDate();
      notifyListeners();
      return;
    }
    if (raw != null) return; // Already set in an unexpected format; don't overwrite.

    try {
      final now = Timestamp.now();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'trialStartDate': now,
      }, SetOptions(merge: true));
      _trialStartDate = now.toDate();
      notifyListeners();
    } catch (e) {
      debugPrint("Error setting trialStartDate: $e");
    }
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
      debugPrint("Error RevenueCat logout: $e");
    }
  }

  Future<void> _identifyRevenueCat(String id) async {
    if (_currentRevenueCatId == id) return;

    try {
      debugPrint("RevenueProvider: Logging in with ID: $id");
      _currentRevenueCatId = id;
      final result = await Purchases.logIn(id);
      _customerInfo = result.customerInfo;
      notifyListeners();
    } catch (e) {
      debugPrint("Error RevenueCat login: $e");
      _currentRevenueCatId = null; // Reset on failure to retry later if needed
    }
  }

  // --- Public Actions ---

  void setCustomerInfo(CustomerInfo? info) {
    _customerInfo = info;
    notifyListeners();
    _syncPremiumStatusToFirestore();
  }

  Future<void> _syncPremiumStatusToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isPremium': isSubscribed,
        'lastPremiumSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error syncing premium status: $e");
    }
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
