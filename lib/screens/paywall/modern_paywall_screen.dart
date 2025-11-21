import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

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

  final Color _primaryColor = const Color(0xFF6B9C5F);
  final Color _backgroundColor = Colors.white;

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
        setState(() {
          final allPackages = offerings.current!.availablePackages;
          final cleanPackages = <Package>[];

          try {
            final annual = allPackages.firstWhere(
              (p) => p.packageType == PackageType.annual,
            );
            cleanPackages.add(annual);
          } catch (_) {
            // Pas d'annuel trouvé, pas grave
          }

          try {
            final monthly = allPackages.firstWhere(
              (p) => p.packageType == PackageType.monthly,
            );
            cleanPackages.add(monthly);
          } catch (_) {
            try {
              final customMonthly = allPackages.firstWhere(
                (p) =>
                    p.packageType == PackageType.custom ||
                    p.packageType == PackageType.unknown,
              );
              cleanPackages.add(customMonthly);
            } catch (e) {}
          }

          _packages = cleanPackages;

          if (_packages.isNotEmpty) {
            _selectedPackage = _packages.firstWhere(
              (p) => p.packageType == PackageType.annual,
              orElse: () => _packages.first,
            );
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur récupération offres: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseSelectedPackage() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);

    try {
      final purchaseResult = await Purchases.purchasePackage(_selectedPackage!);

      if (mounted) {
        context.read<RevenueProvider>().setCustomerInfo(
          purchaseResult.customerInfo,
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paywallSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on PurchasesError catch (e) {
      if (e.code != PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
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
            const SnackBar(content: Text("Achats restaurés avec succès !")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aucun abonnement actif trouvé.")),
          );
        }
      }
    } catch (e) {
      // Gérer erreur
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SafeArea(
              child: Column(
                children: [
                  // --- HEADER & FERMETURE ---
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- TITRE & IMAGE ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.diamond,
                              size: 50,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.paywallTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.paywallSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 40),

                          _buildBenefitItem(
                            Icons.receipt_long,
                            l10n.paywallBenefit1Title,
                            l10n.paywallBenefit1Desc,
                          ),
                          _buildBenefitItem(
                            Icons.restaurant_menu,
                            l10n.paywallBenefit2Title,
                            l10n.paywallBenefit2Desc,
                          ),
                          _buildBenefitItem(
                            Icons.notifications_active,
                            l10n.paywallBenefit3Title,
                            l10n.paywallBenefit3Desc,
                          ),
                          _buildBenefitItem(
                            Icons.qr_code_scanner,
                            l10n.paywallBenefit4Title,
                            l10n.paywallBenefit4Desc,
                          ),
                          _buildBenefitItem(
                            Icons.group,
                            l10n.paywallBenefit5Title,
                            l10n.paywallBenefit5Desc,
                          ),

                          const SizedBox(height: 40),

                          // --- SÉLECTION DU PLAN ---
                          if (_packages.isNotEmpty)
                            ..._packages.map(
                              (pkg) => _buildPackageOption(pkg, l10n),
                            ),

                          const SizedBox(height: 20),

                          // --- BOUTON D'ACTION ---
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isPurchasing
                                  ? null
                                  : _purchaseSelectedPackage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isPurchasing
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      l10n.paywallSubscribeBtn,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --- RESTORE & LEGAL ---
                          TextButton(
                            onPressed: _restorePurchases,
                            child: Text(
                              l10n.paywallRestoreBtn,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.paywallLegalText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // WIDGET : Ligne d'avantage
  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET : Option de prix (Mensuel / Annuel)
  Widget _buildPackageOption(Package package, AppLocalizations l10n) {
    final isSelected = _selectedPackage == package;
    final isAnnual = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAnnual ? l10n.paywallAnnual : l10n.paywallMonthly,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.paywallSaveLabel,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.storeProduct.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Prix
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isAnnual ? "29.99€" : "4.99€",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  isAnnual
                      ? "/ ${l10n.paywallAnnual.toLowerCase()}"
                      : "/ ${l10n.paywallMonthly.toLowerCase()}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
