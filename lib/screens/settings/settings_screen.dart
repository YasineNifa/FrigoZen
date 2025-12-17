import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:frigo_zen/screens/paywall/modern_paywall_screen.dart';
import 'package:frigo_zen/services/household_service.dart';
import 'package:frigo_zen/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/components/skeleton.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frigo_zen/screens/settings/privacy_screen.dart';
import 'package:frigo_zen/repositories/product_catalog_repository.dart' as frigo_zen;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<RevenueProvider>().isPro;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // --- SECTION: ACCOUNT ---
          _buildSectionHeader(context, l10n.settingsAccountInfo),
          if (_user != null)
            _buildProfileTile(context),
          
          const SizedBox(height: 24),

          // --- SECTION: SUBSCRIPTION ---
          _buildSectionHeader(context, l10n.settingsSubscriptionHeader),
          _buildSettingsTile(
            context,
            icon: isPro ? Icons.star : Icons.star_border,
            iconColor: Colors.amber[700],
            title: isPro ? l10n.settingsManageSub : l10n.settingsUpgrade,
            subtitle: isPro ? l10n.settingsProMember : l10n.settingsUnlockFeatures,
            trailing: isPro 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "PRO",
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () async {
              if (isPro) {
                try {
                  await RevenueCatUI.presentCustomerCenter();
                } on PurchasesError {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.settingsErrorOpen)),
                    );
                  }
                }
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const ModernPaywallScreen(),
                  ),
                );
              }
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.restore,
            title: l10n.settingsRestore,
            onTap: () async {
              try {
                final customerInfo = await Purchases.restorePurchases();
                if (context.mounted) {
                  context.read<RevenueProvider>().setCustomerInfo(customerInfo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsRestoreSuccess)),
                  );
                }
              } on PurchasesError catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsRestoreFail(e.message))),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // --- SECTION: HOUSEHOLD ---
          _buildSectionHeader(context, l10n.settingsFamilyHeader),
          StreamBuilder<DocumentSnapshot?>(
            stream: HouseholdService().getCurrentHouseholdStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Skeleton(width: 40, height: 40, borderRadius: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Skeleton(width: 120, height: 16),
                                SizedBox(height: 8),
                                Skeleton(width: 80, height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Skeleton(width: double.infinity, height: 48),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox();
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final String inviteCode = data['inviteCode'] ?? '...';
              final String householdName = data['name'] ?? l10n.settingsDefaultHouse;

              if (!isPro) {
                return _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline,
                  title: l10n.settingsInviteMembers,
                  subtitle: l10n.settingsInvitePremiumHint,
                  trailing: const Icon(Icons.lock, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const ModernPaywallScreen(),
                      ),
                    );
                  },
                );
              } else {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green[50],
                            child: Icon(Icons.home, color: Colors.green[700]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  householdName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  l10n.settingsInviteCodeLabel,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              inviteCode,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              color: theme.primaryColor,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.settingsCodeCopied)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // --- SECTION: ABOUT ---
          _buildSectionHeader(context, l10n.settingsAboutHeader),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: l10n.settingsVersion,
            trailing: const Text(
              "1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: l10n.settingsPrivacyPolicy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen(isTerms: false)),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: l10n.settingsTermsOfService,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen(isTerms: true)),
              );
            },
          ),

          // --- SECTION: DEBUG (HIDDEN) ---
           /* 
            * Debug section removed for production. 
            */
           _buildSectionHeader(context, "MINTENANCE (TEMP)"),
           _buildSettingsTile(
             context,
             icon: Icons.build,
             title: "Reconstruire le Catalogue",
             subtitle: "Importer l'historique et l'inventaire",
             onTap: () async {
                 try {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Migration en cours... (ça peut être long)")),
                   );
                   // Accessing repo usually via Provider or direct instance? 
                   // Since it's a repository not a provider, let's instantiate.
                   final count = await frigo_zen.ProductCatalogRepository().populateCatalogFromHistory();
                   
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Terminé ! $count éléments traités.")),
                     );
                   }
                 } catch (e) {
                    if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Erreur: $e")),
                     );
                   }
                 }
             },
           ),

          const SizedBox(height: 32),

          // --- LOGOUT ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                context.read<RevenueProvider>().setCustomerInfo(null);
                try {
                  final isAnonymous = await Purchases.isAnonymous;
                  if (!isAnonymous) {
                    await Purchases.logOut();
                  }
                } catch (e) {
                  debugPrint("Error logout RevenueCat: $e");
                }
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                l10n.settingsLogout,
                style: const TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }



  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _user?.displayName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsEditProfileTitle),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.settingsDisplayNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.settingsCancelBtn),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _user?.updateDisplayName(nameController.text.trim());
                await _user?.reload();
                final updatedUser = FirebaseAuth.instance.currentUser;
                
                if (mounted) {
                  setState(() {
                    _user = updatedUser;
                  });
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.settingsProfileUpdated)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.settingsErrorGeneric(e.toString()))),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.settingsSaveBtn),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey[700])!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.grey[700], size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  Widget _buildProfileTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasAvatar = _user?.photoURL != null && _user!.photoURL!.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: GestureDetector(
          onTap: _showAvatarSelectionDialog,
          child: Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                  image: hasAvatar
                      ? DecorationImage(
                          image: AssetImage(_user!.photoURL!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasAvatar
                    ? Icon(Icons.person, size: 30, color: Colors.grey[400])
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          _user!.displayName ?? 'Utilisateur',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          _user!.email ?? l10n.settingsNoEmail,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.grey),
          onPressed: _showEditProfileDialog,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAvatarSelectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    final List<String> avatars = [
      'assets/images/avatars/panda.png',
      'assets/images/avatars/fox.png',
      'assets/images/avatars/cat.png',
      'assets/images/avatars/dog.png',
      'assets/images/avatars/koala.png',
      'assets/images/avatars/rabbit.png',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.settingsSelectAvatar,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                final avatar = avatars[index];
                final isSelected = _user?.photoURL == avatar;
                
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await AuthService().updateAvatar(avatar);
                    setState(() {
                      _user = FirebaseAuth.instance.currentUser;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                          : null,
                      boxShadow: [
                         BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ]
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(avatar),
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
