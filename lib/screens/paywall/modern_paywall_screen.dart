import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ModernPaywallScreen extends StatefulWidget {
  const ModernPaywallScreen({super.key});

  @override
  State<ModernPaywallScreen> createState() => _ModernPaywallScreenState();
}

class _ModernPaywallScreenState extends State<ModernPaywallScreen> {
  Package? _selectedPackage;
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  // Coherent Premium Palette
  final Color _primaryColor = const Color(0xFF6B9C5F); // FrigoZen Green
  final Color _surfaceColor = Colors.white;
  final Color _goldColor = const Color(0xFFFFD700); // Gold
  final Color _textDark = Colors.black87;
  final Color _textGrey = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        if (mounted) {
          setState(() {
            final allPackages = offerings.current!.availablePackages;
            final cleanPackages = <Package>[];

            // Prioritize Annual then Monthly
            try {
              final annual = allPackages.firstWhere(
                (p) => p.packageType == PackageType.annual,
              );
              cleanPackages.add(annual);
            } catch (_) {}

            try {
              final monthly = allPackages.firstWhere(
                (p) => p.packageType == PackageType.monthly,
              );
              cleanPackages.add(monthly);
            } catch (_) {}

            // Fallback
            if (cleanPackages.isEmpty) {
              cleanPackages.addAll(allPackages);
            }

            _packages = cleanPackages;

            // Select Annual by default if available
            if (_packages.isNotEmpty) {
              _selectedPackage = _packages.firstWhere(
                (p) => p.packageType == PackageType.annual,
                orElse: () => _packages.first,
              );
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _purchaseSelectedPackage() async {
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);

    try {
      // ignore: deprecated_member_use
      final purchaseResult = await Purchases.purchasePackage(_selectedPackage!);

      if (mounted) {
        context.read<RevenueProvider>().setCustomerInfo(
          purchaseResult.customerInfo,
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paywallSuccess),
            backgroundColor: _primaryColor,
          ),
        );
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled the purchase, do nothing
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Unknown error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    try {
      final customerInfo = await Purchases.restorePurchases();
      if (mounted) {
        context.read<RevenueProvider>().setCustomerInfo(customerInfo);

        if (customerInfo.entitlements.active.isNotEmpty) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.settingsRestoreSuccess)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No active subscription found.")),
          );
        }
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled, do nothing
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsRestoreFail(e.message ?? "Unknown error"))),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rp = context.watch<RevenueProvider>();
    final showTrialEnded = !rp.isSubscribed && rp.isTrialExpired;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Stack(
              children: [
                // Background Image or Gradient
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/zen.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.1,
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // Close Button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Icon / Logo
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 64,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                l10n.paywallTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                showTrialEnded
                                    ? l10n.paywallTrialEndedSubtitle
                                    : l10n.paywallSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Features List
                              _buildFeatureItem(Icons.qr_code_scanner, l10n.paywallBenefit1Title, l10n.paywallBenefit1Desc),
                              _buildFeatureItem(Icons.restaurant_menu, l10n.paywallBenefit2Title, l10n.paywallBenefit2Desc),
                              _buildFeatureItem(Icons.cloud_outlined, l10n.paywallBenefit3Title, l10n.paywallBenefit3Desc),
                              _buildFeatureItem(Icons.family_restroom, l10n.paywallBenefit5Title, l10n.paywallBenefit5Desc),

                              const SizedBox(height: 40),

                              // Packages
                              if (_packages.isNotEmpty)
                                ..._packages.map(
                                  (pkg) => _buildPackageOption(pkg, l10n),
                                ),

                              const SizedBox(height: 24),

                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isPurchasing ? null : _purchaseSelectedPackage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: _primaryColor.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isPurchasing
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          l10n.paywallSubscribeBtn,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Restore Button
                              TextButton(
                                onPressed: _restorePurchases,
                                child: Text(
                                  l10n.paywallRestoreBtn,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Legal Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegalLink(l10n.paywallTermsButton, () async {
                                    const url = 'https://frigozen.com/terms';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  }),
                                  Text(" • ", style: TextStyle(color: Colors.grey[400])),
                                  _buildLegalLink(l10n.settingsPrivacyPolicy, () async {
                                    const url = 'https://frigozen.com/privacy';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  }),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isPurchasing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: _textGrey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(Package package, AppLocalizations l10n) {
    final isSelected = _selectedPackage == package;
    final isAnnual = package.packageType == PackageType.annual;
    final priceString = package.storeProduct.priceString;

    // Calculate monthly equivalent for annual plan
    String? monthlyEquivalent;
    if (isAnnual) {
      final price = package.storeProduct.price;
      final monthlyPrice = price / 12;
      final currencySymbol = package.storeProduct.currencyCode;
      monthlyEquivalent = "${monthlyPrice.toStringAsFixed(2)} $currencySymbol / ${l10n.paywallMonthly.toLowerCase()}";
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _primaryColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Radio Indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _primaryColor : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAnnual ? l10n.paywallAnnual : l10n.paywallMonthly,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _textDark,
                          ),
                        ),
                        if (isAnnual)
                          Text(
                            "12 ${l10n.paywallMonthly.toLowerCase()}", // Approximation
                            style: TextStyle(
                              color: _textGrey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isSelected ? _primaryColor : _textDark,
                        ),
                      ),
                      if (isAnnual && monthlyEquivalent != null)
                        Text(
                          monthlyEquivalent,
                          style: TextStyle(
                            color: _textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Best Value Badge
            if (isAnnual)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _goldColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.paywallSaveLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }
}
