import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueProvider with ChangeNotifier {
  static const String _proEntitlementId = 'frigo_zen Pro';

  CustomerInfo? _customerInfo;

  bool get isPro {
    if (_customerInfo == null) return false;
    return _customerInfo!.entitlements.active[_proEntitlementId] != null;
  }

  Future<void> init() async {
    Purchases.addCustomerInfoUpdateListener((info) {
      _customerInfo = info;
      notifyListeners();
    });

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      print("Error RevenueCat init: $e");
    }
  }

  void setCustomerInfo(CustomerInfo? info) {
    _customerInfo = info;
    notifyListeners();
  }
}
