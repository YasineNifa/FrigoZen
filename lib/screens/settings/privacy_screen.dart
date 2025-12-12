import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyScreen extends StatelessWidget {
  final bool isTerms;

  const PrivacyScreen({super.key, required this.isTerms});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTerms ? "Terms of Service" : "Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          isTerms ? _termsText : _privacyText,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }

  static const String _privacyText = """
Privacy Policy for FrigoZen

Last Updated: December 12, 2025

1. Introduction
Welcome to FrigoZen. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.

2. Data We Collect
We collect the following types of data:
- Inventory Data: Items you scan or add to your fridge/pantry.
- Purchase Data: Information about your subscription status (processed securely by RevenueCat and Apple/Google).
- Usage Data: Anonymous analytics to help us improve the app.

3. How We Use Your Data
We use your data to:
- Manage your inventory and send expiration alerts.
- Process your subscription.
- Improve our services.

4. Data Security
We implement appropriate security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way.

5. Contact Us
If you have any questions about this privacy policy, please contact us support@frigozen.com
""";

  static const String _termsText = """
Terms of Service for FrigoZen

Last Updated: December 12, 2025

1. Acceptance of Terms
By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app.

2. License to Use
FrigoZen is licensed to you for your personal, non-commercial use only.

3. Subscriptions
Some features of the app require a paid subscription. Subscriptions automatically renew unless auto-renew is turned off at least 24-hours before the end of the current period.

4. Limitation of Liability
FrigoZen is not responsible for any food expiry or health issues related to food consumption. The expiration dates provided are estimates.

5. Changes to Terms
We may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes.
""";
}
