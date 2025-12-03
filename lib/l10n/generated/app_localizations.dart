import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FrigoZen'**
  String get appTitle;

  /// No description provided for @inventoryTab.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTab;

  /// No description provided for @shoppingListTab.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shoppingListTab;

  /// No description provided for @favoritesTab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @db_milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get db_milk;

  /// No description provided for @db_chicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get db_chicken;

  /// No description provided for @db_apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get db_apple;

  /// No description provided for @db_tomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get db_tomato;

  /// No description provided for @db_pasta.
  ///
  /// In en, this message translates to:
  /// **'Pasta'**
  String get db_pasta;

  /// No description provided for @db_rice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get db_rice;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FrigoZen'**
  String get authWelcome;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your fridge.'**
  String get authLoginSubtitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start saving.'**
  String get authSignupSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authLoginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginBtn;

  /// No description provided for @authSignupBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignupBtn;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHaveAccount;

  /// No description provided for @authToLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authToLogin;

  /// No description provided for @authSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. You can now log in.'**
  String get authSuccess;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please check your credentials.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorNoUser.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email.'**
  String get authErrorNoUser;

  /// No description provided for @authErrorWrongPass.
  ///
  /// In en, this message translates to:
  /// **'Password is incorrect.'**
  String get authErrorWrongPass;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPass.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get authErrorWeakPass;

  /// No description provided for @authFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get authFieldRequired;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get authInvalidEmail;

  /// No description provided for @authShortPassword.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters long.'**
  String get authShortPassword;

  /// No description provided for @householdWelcome.
  ///
  /// In en, this message translates to:
  /// **'Bienvenue chez vous !'**
  String get householdWelcome;

  /// No description provided for @householdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pour commencer, créez votre espace familial ou rejoignez-en un existant.'**
  String get householdSubtitle;

  /// No description provided for @householdCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Créer un nouvel espace'**
  String get householdCreateTitle;

  /// No description provided for @householdNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nom de la maison (ex: Chez Nous)'**
  String get householdNameLabel;

  /// No description provided for @householdCreateBtn.
  ///
  /// In en, this message translates to:
  /// **'Créer'**
  String get householdCreateBtn;

  /// No description provided for @householdOr.
  ///
  /// In en, this message translates to:
  /// **'OU'**
  String get householdOr;

  /// No description provided for @householdJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejoindre un espace'**
  String get householdJoinTitle;

  /// No description provided for @householdCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code d\'invitation (ex: FZ-1234)'**
  String get householdCodeLabel;

  /// No description provided for @householdJoinBtn.
  ///
  /// In en, this message translates to:
  /// **'Rejoindre'**
  String get householdJoinBtn;

  /// No description provided for @householdErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Le nom est requis'**
  String get householdErrorNameRequired;

  /// No description provided for @householdErrorCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Le code est requis'**
  String get householdErrorCodeRequired;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addItemTitle;

  /// No description provided for @addItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (ex: Milk)'**
  String get addItemNameLabel;

  /// No description provided for @addItemNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get addItemNameError;

  /// No description provided for @addItemQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity : {quantity}'**
  String addItemQuantityLabel(int quantity);

  /// No description provided for @addItemSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addItemSaveBtn;

  /// No description provided for @addItemError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String addItemError(String error);

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Inventory'**
  String get inventoryTitle;

  /// No description provided for @inventoryTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inventoryTabAll;

  /// No description provided for @inventoryTabFridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get inventoryTabFridge;

  /// No description provided for @inventoryTabPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get inventoryTabPantry;

  /// No description provided for @inventoryTabFreezer.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get inventoryTabFreezer;

  /// No description provided for @inventorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for an item...'**
  String get inventorySearchHint;

  /// No description provided for @inventoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your inventory is empty'**
  String get inventoryEmptyTitle;

  /// No description provided for @inventoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add an item or scan a receipt.'**
  String get inventoryEmptySubtitle;

  /// No description provided for @suggestRecipeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Suggest a recipe'**
  String get suggestRecipeTooltip;

  /// No description provided for @scanReceiptCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt (Camera)'**
  String get scanReceiptCamera;

  /// No description provided for @scanReceiptGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get scanReceiptGallery;

  /// No description provided for @scanManual.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get scanManual;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Stop wasting money.'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Desc.
  ///
  /// In en, this message translates to:
  /// **'FrigoZen helps you consume your food before it expires.'**
  String get onboardingPage1Desc;

  /// No description provided for @onboardingPage1Btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingPage1Btn;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Know what to eat.'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Desc.
  ///
  /// In en, this message translates to:
  /// **'Get simple recipes based on what you already have in your fridge.'**
  String get onboardingPage2Desc;

  /// No description provided for @onboardingPage2Btn.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingPage2Btn;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Smart shopping at last.'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Desc.
  ///
  /// In en, this message translates to:
  /// **'Never buy duplicates again. Scan, add, and your list is updated.'**
  String get onboardingPage3Desc;

  /// No description provided for @onboardingPage3Btn.
  ///
  /// In en, this message translates to:
  /// **'Start the adventure'**
  String get onboardingPage3Btn;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHaveAccount;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Take it to the next level'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of your kitchen and save up to €500 per year.'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefit1Title.
  ///
  /// In en, this message translates to:
  /// **'AI Receipt Scanning'**
  String get paywallBenefit1Title;

  /// No description provided for @paywallBenefit1Desc.
  ///
  /// In en, this message translates to:
  /// **'Add your shopping in 2 seconds.'**
  String get paywallBenefit1Desc;

  /// No description provided for @paywallBenefit2Title.
  ///
  /// In en, this message translates to:
  /// **'Magic Recipes'**
  String get paywallBenefit2Title;

  /// No description provided for @paywallBenefit2Desc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited generation with photos.'**
  String get paywallBenefit2Desc;

  /// No description provided for @paywallBenefit3Title.
  ///
  /// In en, this message translates to:
  /// **'Anti-Waste Alerts'**
  String get paywallBenefit3Title;

  /// No description provided for @paywallBenefit3Desc.
  ///
  /// In en, this message translates to:
  /// **'Be warned before it\'s too late.'**
  String get paywallBenefit3Desc;

  /// No description provided for @paywallBenefit4Title.
  ///
  /// In en, this message translates to:
  /// **'Health Scanner'**
  String get paywallBenefit4Title;

  /// No description provided for @paywallBenefit4Desc.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score and product details.'**
  String get paywallBenefit4Desc;

  /// No description provided for @paywallBenefit5Title.
  ///
  /// In en, this message translates to:
  /// **'Family Sharing'**
  String get paywallBenefit5Title;

  /// No description provided for @paywallBenefit5Desc.
  ///
  /// In en, this message translates to:
  /// **'Invite your household.'**
  String get paywallBenefit5Desc;

  /// No description provided for @paywallAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallAnnual;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'SAVE 50%'**
  String get paywallSaveLabel;

  /// No description provided for @paywallSubscribeBtn.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now'**
  String get paywallSubscribeBtn;

  /// No description provided for @paywallRestoreBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestoreBtn;

  /// No description provided for @paywallLegalText.
  ///
  /// In en, this message translates to:
  /// **'No commitment required. Cancellable at any time. By continuing, you agree to the Terms of Service and Privacy Policy.'**
  String get paywallLegalText;

  /// No description provided for @paywallSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the FrigoZen Pro club! 🌟'**
  String get paywallSuccess;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cookbook'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save recipes you like to find them here.'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get favoritesLockedTitle;

  /// No description provided for @favoritesLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to FrigoZen Pro to save your favorite AI-generated recipes and build your personal cookbook.'**
  String get favoritesLockedSubtitle;

  /// No description provided for @favoritesUnlockBtn.
  ///
  /// In en, this message translates to:
  /// **'Unlock Cookbook'**
  String get favoritesUnlockBtn;

  /// No description provided for @favoritesUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled Recipe'**
  String get favoritesUntitled;

  /// No description provided for @favoritesNoDesc.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get favoritesNoDesc;

  /// No description provided for @recipeDetailUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled Recipe'**
  String get recipeDetailUntitled;

  /// No description provided for @recipeDetailNoDesc.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get recipeDetailNoDesc;

  /// No description provided for @recipeDetailFridge.
  ///
  /// In en, this message translates to:
  /// **'YOUR FRIDGE'**
  String get recipeDetailFridge;

  /// No description provided for @recipeDetailToBuy.
  ///
  /// In en, this message translates to:
  /// **'TO BUY'**
  String get recipeDetailToBuy;

  /// No description provided for @recipeDetailPreparation.
  ///
  /// In en, this message translates to:
  /// **'PREPARATION'**
  String get recipeDetailPreparation;

  /// No description provided for @recipeDetailSaved.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved to Favorites! ❤️'**
  String get recipeDetailSaved;

  /// No description provided for @recipeDetailRemoved.
  ///
  /// In en, this message translates to:
  /// **'Recipe removed from Favorites.'**
  String get recipeDetailRemoved;

  /// No description provided for @recipeDetailError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String recipeDetailError(String error);

  /// No description provided for @recipeSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Ideas'**
  String get recipeSuggestionTitle;

  /// No description provided for @recipeSuggestionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes found for this combination. :('**
  String get recipeSuggestionEmpty;

  /// No description provided for @recipeSuggestionUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled Recipe'**
  String get recipeSuggestionUntitled;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get settingsAccountInfo;

  /// No description provided for @settingsNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email available'**
  String get settingsNoEmail;

  /// No description provided for @settingsManageSub.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get settingsManageSub;

  /// No description provided for @settingsUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to FrigoZen Pro'**
  String get settingsUpgrade;

  /// No description provided for @settingsProMember.
  ///
  /// In en, this message translates to:
  /// **'You are a Pro member.'**
  String get settingsProMember;

  /// No description provided for @settingsUnlockFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features.'**
  String get settingsUnlockFeatures;

  /// No description provided for @settingsErrorOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings'**
  String get settingsErrorOpen;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsRestore;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully.'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreFail.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String settingsRestoreFail(String error);

  /// No description provided for @settingsFamilyHeader.
  ///
  /// In en, this message translates to:
  /// **'FAMILY & HOUSEHOLD'**
  String get settingsFamilyHeader;

  /// No description provided for @settingsDefaultHouse.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get settingsDefaultHouse;

  /// No description provided for @settingsInviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get settingsInviteMembers;

  /// No description provided for @settingsInvitePremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Go Premium to share your inventory.'**
  String get settingsInvitePremiumHint;

  /// No description provided for @settingsInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code :'**
  String get settingsInviteCodeLabel;

  /// No description provided for @settingsCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get settingsCodeCopied;

  /// No description provided for @settingsShareHint.
  ///
  /// In en, this message translates to:
  /// **'Share this code to invite your family.'**
  String get settingsShareHint;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingTitle;

  /// No description provided for @shoppingItemNoTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Item'**
  String get shoppingItemNoTitle;

  /// No description provided for @shoppingDuplicateAlert.
  ///
  /// In en, this message translates to:
  /// **'💡 Attention! You already have \"{itemName}\" in your inventory!'**
  String shoppingDuplicateAlert(String itemName);

  /// No description provided for @shoppingAddAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add Anyway'**
  String get shoppingAddAnyway;

  /// No description provided for @shoppingErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String shoppingErrorGeneric(String error);

  /// No description provided for @shoppingMovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) moved to Inventory successfully!'**
  String shoppingMovedSuccess(int count);

  /// No description provided for @shoppingMoveError.
  ///
  /// In en, this message translates to:
  /// **'Error moving items: {error}'**
  String shoppingMoveError(String error);

  /// No description provided for @shoppingAddingBtn.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get shoppingAddingBtn;

  /// No description provided for @shoppingMoveBtn.
  ///
  /// In en, this message translates to:
  /// **'Add {count} item(s) to Inventory'**
  String shoppingMoveBtn(int count);

  /// No description provided for @validationTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate items ({count})'**
  String validationTitle(int count);

  /// No description provided for @validationCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get validationCancelBtn;

  /// No description provided for @validationAddBtn.
  ///
  /// In en, this message translates to:
  /// **'Add {count} items'**
  String validationAddBtn(int count);

  /// No description provided for @validationSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} items added to inventory!'**
  String validationSuccess(int count);

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Error adding items: {error}'**
  String validationError(String error);

  /// No description provided for @shoppingListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get shoppingListEmptyTitle;

  /// No description provided for @shoppingListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add an item using the field above to get started.'**
  String get shoppingListEmptySubtitle;

  /// No description provided for @inputFieldHintText.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get inputFieldHintText;

  /// No description provided for @editBatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage dates : {itemName}'**
  String editBatchesTitle(String itemName);

  /// No description provided for @editBatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click the pencil to change a batch date.'**
  String get editBatchesSubtitle;

  /// No description provided for @editBatchesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No date information.'**
  String get editBatchesEmpty;

  /// No description provided for @editBatchesExpiredPrefix.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED ON'**
  String get editBatchesExpiredPrefix;

  /// No description provided for @editBatchesExpiresPrefix.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get editBatchesExpiresPrefix;

  /// No description provided for @editBatchesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Date updated successfully! ✅'**
  String get editBatchesSuccess;

  /// No description provided for @editBatchesError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String editBatchesError(String error);

  /// No description provided for @mealPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'My Meal Planner'**
  String get mealPlannerTitle;

  /// No description provided for @mealPlannerGenerateList.
  ///
  /// In en, this message translates to:
  /// **'Generate shopping list'**
  String get mealPlannerGenerateList;

  /// No description provided for @mealPlannerLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch ☀️'**
  String get mealPlannerLunch;

  /// No description provided for @mealPlannerDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner 🌙'**
  String get mealPlannerDinner;

  /// No description provided for @mealPlannerAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add a meal'**
  String get mealPlannerAddMeal;

  /// No description provided for @mealPlannerEditMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get mealPlannerEditMeal;

  /// No description provided for @mealPlannerMealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealPlannerMealNameLabel;

  /// No description provided for @mealPlannerMealNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Carbonara Pasta'**
  String get mealPlannerMealNameHint;

  /// No description provided for @mealPlannerIngredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredients (comma separated)'**
  String get mealPlannerIngredientsLabel;

  /// No description provided for @mealPlannerIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Pasta, Bacon, Cream, Eggs'**
  String get mealPlannerIngredientsHint;

  /// No description provided for @mealPlannerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mealPlannerCancel;

  /// No description provided for @mealPlannerModify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get mealPlannerModify;

  /// No description provided for @mealPlannerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get mealPlannerAdd;

  /// No description provided for @mealPlannerAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing inventory and generating list... ⏳'**
  String get mealPlannerAnalyzing;

  /// No description provided for @mealPlannerAddedIngredients.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients added to the list!'**
  String mealPlannerAddedIngredients(int count);

  /// No description provided for @mealPlannerViewList.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get mealPlannerViewList;

  /// No description provided for @paywallBenefitSmartListTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart List'**
  String get paywallBenefitSmartListTitle;

  /// No description provided for @paywallBenefitSmartListDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatic and smart generation.'**
  String get paywallBenefitSmartListDesc;

  /// No description provided for @mealPlannerSmartListUpsell.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for AI-powered smart list generation!'**
  String get mealPlannerSmartListUpsell;

  /// No description provided for @mealPlannerGoPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get mealPlannerGoPremium;

  /// No description provided for @paywallTermsButton.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get paywallTermsButton;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @scanActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanActionLabel;

  /// No description provided for @addActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addActionLabel;

  /// No description provided for @mealPlannerCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My Meal Planner'**
  String get mealPlannerCardTitle;

  /// No description provided for @mealPlannerCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your weekly meals'**
  String get mealPlannerCardSubtitle;

  /// No description provided for @expiringSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat Soon!'**
  String get expiringSoonTitle;

  /// No description provided for @cookWithFridgeBtn.
  ///
  /// In en, this message translates to:
  /// **'Cook with my fridge'**
  String get cookWithFridgeBtn;

  /// No description provided for @summaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get summaryTotal;

  /// No description provided for @summaryToEat.
  ///
  /// In en, this message translates to:
  /// **'To eat'**
  String get summaryToEat;

  /// No description provided for @summaryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get summaryShopping;

  /// No description provided for @expiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @daysLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'D-{days}'**
  String daysLeftLabel(int days);

  /// No description provided for @statsTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get statsTopCategories;

  /// No description provided for @statsNutriScore.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Quality'**
  String get statsNutriScore;

  /// No description provided for @statsScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String statsScoreLabel(String score);

  /// No description provided for @statsPremiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Premium Statistics'**
  String get statsPremiumLabel;

  /// No description provided for @statsUnlockBtn.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get statsUnlockBtn;

  /// No description provided for @statsStorageDistribution.
  ///
  /// In en, this message translates to:
  /// **'Storage Distribution'**
  String get statsStorageDistribution;

  /// No description provided for @statsFavoriteStores.
  ///
  /// In en, this message translates to:
  /// **'Your Favorite Stores'**
  String get statsFavoriteStores;

  /// No description provided for @recipeFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding recipes...'**
  String get recipeFinding;

  /// No description provided for @inventoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your inventory is empty!'**
  String get inventoryEmpty;

  /// No description provided for @recipesNotFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found.'**
  String get recipesNotFound;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @renameProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename product'**
  String get renameProductTitle;

  /// No description provided for @newNameLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newNameLabel;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @renameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameTooltip;

  /// No description provided for @addedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Added on {date}'**
  String addedOnDate(String date);

  /// No description provided for @editBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit batch'**
  String get editBatchTitle;

  /// No description provided for @specificNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Specific name'**
  String get specificNameLabel;

  /// No description provided for @specificNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Organic Eggs'**
  String get specificNameHint;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @brandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bio Village'**
  String get brandHint;

  /// No description provided for @storeLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeLabel;

  /// No description provided for @storeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Whole Foods'**
  String get storeHint;

  /// No description provided for @nutriScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score'**
  String get nutriScoreLabel;

  /// No description provided for @nutriScoreUndefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get nutriScoreUndefined;

  /// No description provided for @expirationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDateLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// No description provided for @searchTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get searchTryDifferent;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get statusExpiresToday;

  /// No description provided for @statusExpiresSoon.
  ///
  /// In en, this message translates to:
  /// **'Expires soon'**
  String get statusExpiresSoon;

  /// No description provided for @statusExpiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String statusExpiresInDays(int days);

  /// No description provided for @statusFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get statusFresh;

  /// No description provided for @scanBarcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get scanBarcodeTitle;

  /// No description provided for @productUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get productUnknown;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added!'**
  String productAdded(String name);

  /// No description provided for @productNotFoundOFF.
  ///
  /// In en, this message translates to:
  /// **'Product not found in Open Food Facts.'**
  String get productNotFoundOFF;

  /// No description provided for @serverErrorOFF.
  ///
  /// In en, this message translates to:
  /// **'OFF Server Error ({code})'**
  String serverErrorOFF(Object code);

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @shoppingItemAlreadyInStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Item already in stock'**
  String get shoppingItemAlreadyInStockTitle;

  /// No description provided for @shoppingItemAlreadyInStockMessage.
  ///
  /// In en, this message translates to:
  /// **'You already have \'{itemName}\' in your inventory. Do you want to add it to the shopping list anyway?'**
  String shoppingItemAlreadyInStockMessage(String itemName);

  /// No description provided for @shoppingDialogNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get shoppingDialogNo;

  /// No description provided for @shoppingDialogYesAdd.
  ///
  /// In en, this message translates to:
  /// **'Yes, add'**
  String get shoppingDialogYesAdd;

  /// No description provided for @shoppingFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping finished! 🎉'**
  String get shoppingFinishedTitle;

  /// No description provided for @shoppingDialogStay.
  ///
  /// In en, this message translates to:
  /// **'Stay here'**
  String get shoppingDialogStay;

  /// No description provided for @shoppingDialogViewInventory.
  ///
  /// In en, this message translates to:
  /// **'View Inventory'**
  String get shoppingDialogViewInventory;

  /// No description provided for @shoppingUncheckAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Uncheck all'**
  String get shoppingUncheckAllTooltip;

  /// No description provided for @shoppingCheckAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Check all'**
  String get shoppingCheckAllTooltip;

  /// No description provided for @shoppingDeleteAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get shoppingDeleteAllTooltip;

  /// No description provided for @shoppingDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all?'**
  String get shoppingDeleteAllTitle;

  /// No description provided for @shoppingDeleteAllMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to clear your shopping list? This action is irreversible.'**
  String get shoppingDeleteAllMessage;

  /// No description provided for @shoppingDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get shoppingDialogCancel;

  /// No description provided for @shoppingDialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get shoppingDialogDelete;

  /// No description provided for @shoppingCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get shoppingCategoryOther;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipeTitle;

  /// No description provided for @recipeTabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get recipeTabDiscover;

  /// No description provided for @recipeTabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get recipeTabFavorites;

  /// No description provided for @recipeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a recipe...'**
  String get recipeSearchHint;

  /// No description provided for @recipeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No recipes found.'**
  String get recipeNoResults;

  /// No description provided for @recipeIngredientsAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients added!'**
  String get recipeIngredientsAddedTitle;

  /// No description provided for @recipeIngredientsAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ingredients have been added to your shopping list. Do you want to see it now?'**
  String get recipeIngredientsAddedMessage;

  /// No description provided for @recipeDialogStay.
  ///
  /// In en, this message translates to:
  /// **'Stay here'**
  String get recipeDialogStay;

  /// No description provided for @recipeDialogViewList.
  ///
  /// In en, this message translates to:
  /// **'View list'**
  String get recipeDialogViewList;

  /// No description provided for @recipeAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding items: {error}'**
  String recipeAddError(String error);

  /// No description provided for @recipeMealTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Which meal?'**
  String get recipeMealTypeTitle;

  /// No description provided for @recipeMealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch ☀️'**
  String get recipeMealTypeLunch;

  /// No description provided for @recipeMealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner 🌙'**
  String get recipeMealTypeDinner;

  /// No description provided for @recipeAddedToPlanning.
  ///
  /// In en, this message translates to:
  /// **'Recipe added to planner!'**
  String get recipeAddedToPlanning;

  /// No description provided for @recipeViewPlanning.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get recipeViewPlanning;

  /// No description provided for @recipeError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String recipeError(String error);

  /// No description provided for @recipeIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredientsTitle;

  /// No description provided for @recipeAddIngredientsBtn.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get recipeAddIngredientsBtn;

  /// No description provided for @recipeFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Chef Preferences'**
  String get recipeFilterTitle;

  /// No description provided for @recipeFilterMealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get recipeFilterMealType;

  /// No description provided for @recipeFilterDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get recipeFilterDiet;

  /// No description provided for @recipeFilterDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get recipeFilterDifficulty;

  /// No description provided for @recipeFilterGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get recipeFilterGenerate;

  /// No description provided for @recipeFilterCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get recipeFilterCancel;

  /// No description provided for @settingsSubscriptionHeader.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscriptionHeader;

  /// No description provided for @settingsAboutHeader.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutHeader;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfileTitle;

  /// No description provided for @settingsDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get settingsDisplayNameLabel;

  /// No description provided for @settingsCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancelBtn;

  /// No description provided for @settingsSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSaveBtn;

  /// No description provided for @settingsProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get settingsProfileUpdated;

  /// No description provided for @settingsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String settingsErrorGeneric(String error);

  /// No description provided for @householdNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Household name is required'**
  String get householdNameRequired;

  /// No description provided for @householdCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Invitation code is required'**
  String get householdCodeRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
