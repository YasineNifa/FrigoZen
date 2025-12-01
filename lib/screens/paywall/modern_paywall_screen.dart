import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Coherent Premium Palette (Matches AppTheme)
  final Color _primaryColor = const Color(0xFF6B9C5F); // FrigoZen Green
  final Color _backgroundColor = const Color(0xFFF9F9F9); // App Background
  final Color _surfaceColor = Colors.white; // Card Color
  final Color _accentColor = const Color(0xFFFFD700); // Gold (for Badge only)
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
    } catch (e) {
      debugPrint("Erreur récupération offres: $e");
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
            backgroundColor: _primaryColor,
          ),
        );
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Erreur inconnue"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
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
          : Stack(
              children: [
                // Subtle Background Decoration
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryColor.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryColor.withOpacity(0.05),
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // --- HEADER & FERMETURE ---
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: _textGrey),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              // --- ICONE PREMIUM ---
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryColor.withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.workspace_premium,
                                  size: 48,
                                  color: _primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // --- TITRE ---
                              Text(
                                "FRIGOZEN PREMIUM",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: _primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Devenez un Chef Pro",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _textDark,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Débloquez tout le potentiel de votre cuisine avec nos outils professionnels.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _textGrey,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 40),

                              // --- FEATURES ---
                              _buildFeatureItem(
                                Icons.camera_alt_outlined,
                                "Scan Illimité",
                                "Reconnaissance instantanée de vos tickets.",
                              ),
                              _buildFeatureItem(
                                Icons.auto_awesome,
                                "Chef IA & Photos HD",
                                "Recettes sur-mesure et photos générées.",
                              ),
                              _buildFeatureItem(
                                Icons.insights,
                                "Statistiques Avancées",
                                "Analysez votre consommation et votre santé.",
                              ),
                              _buildFeatureItem(
                                Icons.cloud_outlined,
                                "Alertes Cloud",
                                "Notifications anti-gaspillage automatiques.",
                              ),

                              const SizedBox(height: 40),

                              // --- SÉLECTION DU PLAN ---
                              if (_packages.isNotEmpty)
                                ..._packages.map(
                                  (pkg) => _buildPackageOption(pkg, l10n),
                                ),

                              const SizedBox(height: 24),

                              // --- BOUTON D'ACTION ---
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isPurchasing
                                      ? null
                                      : _purchaseSelectedPackage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: _primaryColor.withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isPurchasing
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "COMMENCER MAINTENANT",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // --- RESTORE & LEGAL ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: _restorePurchases,
                                    child: Text(
                                      l10n.paywallRestoreBtn,
                                      style: TextStyle(
                                        color: _textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text("•", style: TextStyle(color: _textGrey)),
                                  TextButton(
                                    onPressed: () {}, // TODO: Add terms link
                                    child: Text(
                                      "Conditions",
                                      style: TextStyle(
                                        color: _textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
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
              color: _primaryColor.withOpacity(0.1),
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
      
      // Attempt to extract currency symbol/code from priceString
      // e.g. "$79.99" -> "$" or "79,99 €" -> "€"
      // Simple heuristic: remove digits, dots, commas, and spaces
      String currencySymbol = package.storeProduct.currencyCode; // Default to code (USD, EUR)
      
      // Try to find a symbol in the priceString if possible, otherwise fallback to code
      // This is a basic approximation.
      final symbolMatch = RegExp(r'[^\d\.,\s]+').firstMatch(priceString);
      if (symbolMatch != null) {
        currencySymbol = symbolMatch.group(0) ?? currencySymbol;
      }

      // Format: "6.66 € / mois" or "$6.66 / mois"
      // We'll place the symbol at the end for consistency with typical EU formatting if it was EU,
      // but since we don't know the locale perfectly, we'll try to mimic the priceString position?
      // Too complex. Let's just append the code/symbol.
      
      monthlyEquivalent = "${monthlyPrice.toStringAsFixed(2)} $currencySymbol / mois";
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
                  ? _primaryColor.withOpacity(0.15) 
                  : Colors.black.withOpacity(0.04),
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
                          isAnnual ? "Annuel" : "Mensuel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _textDark,
                          ),
                        ),
                        if (isAnnual)
                          Text(
                            "12 mois d'accès illimité",
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
                    color: _accentColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(
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
}
