// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FrigoZen';

  @override
  String get inventoryTab => 'Inventory';

  @override
  String get shoppingListTab => 'Shopping';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get settingsTab => 'Settings';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get db_milk => 'Milk';

  @override
  String get db_chicken => 'Chicken';

  @override
  String get db_apple => 'Apple';

  @override
  String get db_tomato => 'Tomato';

  @override
  String get db_pasta => 'Pasta';

  @override
  String get db_rice => 'Rice';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authWelcome => 'Welcome to FrigoZen';

  @override
  String get authLoginSubtitle => 'Log in to manage your fridge.';

  @override
  String get authSignupSubtitle => 'Create an account to start saving.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginBtn => 'Login';

  @override
  String get authSignupBtn => 'Sign up';

  @override
  String get authNoAccount => 'No account? ';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authToLogin => 'Login';

  @override
  String get authSuccess => 'Account created successfully. You can now log in.';

  @override
  String get authErrorGeneric =>
      'An error occurred, please check your credentials.';

  @override
  String get authErrorNoUser => 'No user found for that email.';

  @override
  String get authErrorWrongPass => 'Password is incorrect.';

  @override
  String get authErrorEmailInUse => 'This email is already in use.';

  @override
  String get authErrorWeakPass => 'The password is too weak.';

  @override
  String get authFieldRequired => 'This field is required.';

  @override
  String get authInvalidEmail => 'Please enter a valid email.';

  @override
  String get authShortPassword =>
      'The password must be at least 6 characters long.';

  @override
  String get householdWelcome => 'Welcome home!';

  @override
  String get householdSubtitle =>
      'To get started, create your family space or join an existing one.';

  @override
  String get householdCreateTitle => 'Create a new space';

  @override
  String get householdNameLabel => 'Household name (e.g. Our Home)';

  @override
  String get householdCreateBtn => 'Create';

  @override
  String get householdOr => 'OR';

  @override
  String get householdJoinTitle => 'Join a space';

  @override
  String get householdCodeLabel => 'Invitation code (e.g. FZ-1234)';

  @override
  String get householdJoinBtn => 'Join';

  @override
  String get householdErrorNameRequired => 'Name is required';

  @override
  String get householdErrorCodeRequired => 'Code is required';

  @override
  String get addItemTitle => 'Add New Item';

  @override
  String get addItemNameLabel => 'Name (ex: Milk)';

  @override
  String get addItemNameError => 'Please enter a name.';

  @override
  String addItemQuantityLabel(int quantity) {
    return 'Quantity : $quantity';
  }

  @override
  String get addItemSaveBtn => 'Save';

  @override
  String addItemError(String error) {
    return 'Error: $error';
  }

  @override
  String get inventoryTitle => 'My Inventory';

  @override
  String get inventoryTabAll => 'All';

  @override
  String get inventoryTabFridge => 'Fridge';

  @override
  String get inventoryTabPantry => 'Pantry';

  @override
  String get inventoryTabFreezer => 'Freezer';

  @override
  String get inventorySearchHint => 'Search for an item...';

  @override
  String get inventoryEmptyTitle => 'Your inventory is empty';

  @override
  String get inventoryEmptySubtitle =>
      'Tap + to add an item or scan a receipt.';

  @override
  String get suggestRecipeTooltip => 'Suggest a recipe';

  @override
  String get scanReceiptCamera => 'Scan receipt (Camera)';

  @override
  String get scanReceiptGallery => 'Select from gallery';

  @override
  String get scanManual => 'Add manually';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPage1Title => 'Stop wasting money.';

  @override
  String get onboardingPage1Desc =>
      'FrigoZen helps you consume your food before it expires.';

  @override
  String get onboardingPage1Btn => 'Continue';

  @override
  String get onboardingPage2Title => 'Know what to eat.';

  @override
  String get onboardingPage2Desc =>
      'Get simple recipes based on what you already have in your fridge.';

  @override
  String get onboardingPage2Btn => 'Start';

  @override
  String get onboardingPage3Title => 'Smart shopping at last.';

  @override
  String get onboardingPage3Desc =>
      'Never buy duplicates again. Scan, add, and your list is updated.';

  @override
  String get onboardingPage3Btn => 'Start the adventure';

  @override
  String get onboardingHaveAccount => 'I already have an account';

  @override
  String get paywallTitle => 'Take it to the next level';

  @override
  String get paywallSubtitle =>
      'Unlock the full potential of your kitchen and save up to €500 per year.';

  @override
  String get paywallBenefit1Title => 'AI Receipt Scanning';

  @override
  String get paywallBenefit1Desc => 'Add your shopping in 2 seconds.';

  @override
  String get paywallBenefit2Title => 'Magic Recipes';

  @override
  String get paywallBenefit2Desc => 'Unlimited generation with photos.';

  @override
  String get paywallBenefit3Title => 'Anti-Waste Alerts';

  @override
  String get paywallBenefit3Desc => 'Be warned before it\'s too late.';

  @override
  String get paywallBenefit4Title => 'Health Scanner';

  @override
  String get paywallBenefit4Desc => 'Nutri-Score and product details.';

  @override
  String get paywallBenefit5Title => 'Family Sharing';

  @override
  String get paywallBenefit5Desc => 'Invite your household.';

  @override
  String get paywallAnnual => 'Annual';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallSaveLabel => 'SAVE 50%';

  @override
  String get paywallSubscribeBtn => 'Subscribe now';

  @override
  String get paywallRestoreBtn => 'Restore purchases';

  @override
  String get paywallLegalText =>
      'No commitment required. Cancellable at any time. By continuing, you agree to the Terms of Service and Privacy Policy.';

  @override
  String get paywallSuccess => 'Welcome to the FrigoZen Pro club! 🌟';

  @override
  String get favoritesTitle => 'My Cookbook';

  @override
  String get favoritesEmptyTitle => 'No favorite recipes yet';

  @override
  String get favoritesEmptySubtitle =>
      'Save recipes you like to find them here.';

  @override
  String get favoritesLockedTitle => 'Premium Feature';

  @override
  String get favoritesLockedSubtitle =>
      'Upgrade to FrigoZen Pro to save your favorite AI-generated recipes and build your personal cookbook.';

  @override
  String get favoritesUnlockBtn => 'Unlock Cookbook';

  @override
  String get favoritesUntitled => 'Untitled Recipe';

  @override
  String get favoritesNoDesc => 'No description.';

  @override
  String get recipeDetailUntitled => 'Untitled Recipe';

  @override
  String get recipeDetailNoDesc => 'No description available.';

  @override
  String get recipeDetailFridge => 'YOUR FRIDGE';

  @override
  String get recipeDetailToBuy => 'TO BUY';

  @override
  String get recipeDetailPreparation => 'PREPARATION';

  @override
  String get recipeDetailSaved => 'Recipe saved to Favorites! ❤️';

  @override
  String get recipeDetailRemoved => 'Recipe removed from Favorites.';

  @override
  String recipeDetailError(String error) {
    return 'Error: $error';
  }

  @override
  String get recipeSuggestionTitle => 'Recipe Ideas';

  @override
  String get recipeSuggestionEmpty =>
      'No recipes found for this combination. :(';

  @override
  String get recipeSuggestionUntitled => 'Untitled Recipe';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountInfo => 'Account Information';

  @override
  String get settingsNoEmail => 'No email available';

  @override
  String get settingsManageSub => 'Manage Subscription';

  @override
  String get settingsUpgrade => 'Upgrade to FrigoZen Pro';

  @override
  String get settingsProMember => 'You are a Pro member.';

  @override
  String get settingsUnlockFeatures => 'Unlock all features.';

  @override
  String get settingsErrorOpen => 'Could not open settings';

  @override
  String get settingsRestore => 'Restore Purchases';

  @override
  String get settingsRestoreSuccess => 'Purchases restored successfully.';

  @override
  String settingsRestoreFail(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get settingsFamilyHeader => 'FAMILY & HOUSEHOLD';

  @override
  String get settingsDefaultHouse => 'Home';

  @override
  String get settingsInviteMembers => 'Invite members';

  @override
  String get settingsInvitePremiumHint => 'Go Premium to share your inventory.';

  @override
  String get settingsInviteCodeLabel => 'Invitation Code :';

  @override
  String get settingsCodeCopied => 'Code copied!';

  @override
  String get settingsShareHint => 'Share this code to invite your family.';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get shoppingTitle => 'Shopping List';

  @override
  String get shoppingItemNoTitle => 'Unknown Item';

  @override
  String shoppingDuplicateAlert(String itemName) {
    return '💡 Attention! You already have \"$itemName\" in your inventory!';
  }

  @override
  String get shoppingAddAnyway => 'Add Anyway';

  @override
  String shoppingErrorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String shoppingMovedSuccess(int count) {
    return '$count item(s) moved to Inventory successfully!';
  }

  @override
  String shoppingMoveError(String error) {
    return 'Error moving items: $error';
  }

  @override
  String get shoppingAddingBtn => 'Adding...';

  @override
  String shoppingMoveBtn(int count) {
    return 'Add $count item(s) to Inventory';
  }

  @override
  String validationTitle(int count) {
    return 'Validate items ($count)';
  }

  @override
  String get validationCancelBtn => 'Cancel';

  @override
  String validationAddBtn(int count) {
    return 'Add $count items';
  }

  @override
  String validationSuccess(int count) {
    return '$count items added to inventory!';
  }

  @override
  String validationError(String error) {
    return 'Error adding items: $error';
  }

  @override
  String get shoppingListEmptyTitle => 'Your shopping list is empty';

  @override
  String get shoppingListEmptySubtitle =>
      'Add an item using the field above to get started.';

  @override
  String get inputFieldHintText => 'Add to shopping list';

  @override
  String editBatchesTitle(String itemName) {
    return 'Manage dates : $itemName';
  }

  @override
  String get editBatchesSubtitle => 'Click the pencil to change a batch date.';

  @override
  String get editBatchesEmpty => 'No date information.';

  @override
  String get editBatchesExpiredPrefix => 'EXPIRED ON';

  @override
  String get editBatchesExpiresPrefix => 'Expires on';

  @override
  String get editBatchesSuccess => 'Date updated successfully! ✅';

  @override
  String editBatchesError(String error) {
    return 'Error: $error';
  }

  @override
  String get mealPlannerTitle => 'My Meal Planner';

  @override
  String get mealPlannerGenerateList => 'Generate shopping list';

  @override
  String get mealPlannerBreakfast => 'Breakfast ☕';

  @override
  String get mealPlannerLunch => 'Lunch ☀️';

  @override
  String get mealPlannerSnack => 'Snack 🍎';

  @override
  String get mealPlannerDinner => 'Dinner 🌙';

  @override
  String get mealPlannerAddMeal => 'Add a meal';

  @override
  String get mealPlannerEditMeal => 'Edit meal';

  @override
  String get mealPlannerMealNameLabel => 'Meal name';

  @override
  String get mealPlannerMealNameHint => 'Ex: Carbonara Pasta';

  @override
  String get mealPlannerIngredientsLabel => 'Ingredients (comma separated)';

  @override
  String get mealPlannerIngredientsHint => 'Ex: Pasta, Bacon, Cream, Eggs';

  @override
  String get mealPlannerCancel => 'Cancel';

  @override
  String get mealPlannerModify => 'Modify';

  @override
  String get mealPlannerAdd => 'Add';

  @override
  String get mealPlannerAnalyzing =>
      'Analyzing inventory and generating list... ⏳';

  @override
  String mealPlannerAddedIngredients(int count) {
    return '$count ingredients added to the list!';
  }

  @override
  String get mealPlannerViewList => 'VIEW';

  @override
  String get paywallBenefitSmartListTitle => 'Smart List';

  @override
  String get paywallBenefitSmartListDesc => 'Automatic and smart generation.';

  @override
  String get mealPlannerSmartListUpsell =>
      'Upgrade to Pro for AI-powered smart list generation!';

  @override
  String get mealPlannerGoPremium => 'Go Premium';

  @override
  String get paywallTermsButton => 'Terms & Conditions';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get scanActionLabel => 'Scan';

  @override
  String get addActionLabel => 'Add';

  @override
  String get mealPlannerCardTitle => 'My Meal Planner';

  @override
  String get mealPlannerCardSubtitle => 'Plan your weekly meals';

  @override
  String get expiringSoonTitle => 'Eat Soon!';

  @override
  String get cookWithFridgeBtn => 'Cook with my fridge';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryToEat => 'To eat';

  @override
  String get summaryShopping => 'Shopping';

  @override
  String get expiredLabel => 'Expired';

  @override
  String get todayLabel => 'Today';

  @override
  String daysLeftLabel(int days) {
    return 'D-$days';
  }

  @override
  String get statsTopCategories => 'Top Categories';

  @override
  String get statsNutriScore => 'Nutritional Quality';

  @override
  String statsScoreLabel(String score) {
    return 'Score $score';
  }

  @override
  String get statsPremiumLabel => 'Premium Statistics';

  @override
  String get statsUnlockBtn => 'Unlock';

  @override
  String get statsStorageDistribution => 'Storage Distribution';

  @override
  String get statsFavoriteStores => 'Your Favorite Stores';

  @override
  String get recipeFinding => 'Finding recipes...';

  @override
  String get inventoryEmpty => 'Your inventory is empty!';

  @override
  String get recipesNotFound => 'No recipes found.';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get renameProductTitle => 'Rename product';

  @override
  String get newNameLabel => 'New name';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get saveBtn => 'Save';

  @override
  String get renameTooltip => 'Rename';

  @override
  String addedOnDate(String date) {
    return 'Added on $date';
  }

  @override
  String get editBatchTitle => 'Edit batch';

  @override
  String get specificNameLabel => 'Specific name';

  @override
  String get specificNameHint => 'e.g. Organic Eggs';

  @override
  String get brandLabel => 'Brand';

  @override
  String get brandHint => 'e.g. Bio Village';

  @override
  String get storeLabel => 'Store';

  @override
  String get storeHint => 'e.g. Whole Foods';

  @override
  String get nutriScoreLabel => 'Nutri-Score';

  @override
  String get nutriScoreUndefined => 'Undefined';

  @override
  String get expirationDateLabel => 'Expiration date';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchTryDifferent => 'Try a different search term.';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusExpiresToday => 'Expires today';

  @override
  String get statusExpiresSoon => 'Expires soon';

  @override
  String statusExpiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String get statusFresh => 'Fresh';

  @override
  String get scanBarcodeTitle => 'Scan a barcode';

  @override
  String get productUnknown => 'Unknown product';

  @override
  String productAdded(String name) {
    return '$name added!';
  }

  @override
  String get productNotFoundOFF => 'Product not found in Open Food Facts.';

  @override
  String serverErrorOFF(Object code) {
    return 'OFF Server Error ($code)';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get shoppingItemAlreadyInStockTitle => 'Item already in stock';

  @override
  String shoppingItemAlreadyInStockMessage(String itemName) {
    return 'You already have \'$itemName\' in your inventory. Do you want to add it to the shopping list anyway?';
  }

  @override
  String get shoppingDialogNo => 'No';

  @override
  String get shoppingDialogYesAdd => 'Yes, add';

  @override
  String get shoppingFinishedTitle => 'Shopping finished! 🎉';

  @override
  String get shoppingDialogStay => 'Stay here';

  @override
  String get shoppingDialogViewInventory => 'View Inventory';

  @override
  String get shoppingUncheckAllTooltip => 'Uncheck all';

  @override
  String get shoppingCheckAllTooltip => 'Check all';

  @override
  String get shoppingDeleteAllTooltip => 'Delete all';

  @override
  String get shoppingDeleteAllTitle => 'Delete all?';

  @override
  String get shoppingDeleteAllMessage =>
      'Do you really want to clear your shopping list? This action is irreversible.';

  @override
  String get shoppingDialogCancel => 'Cancel';

  @override
  String get shoppingDialogDelete => 'Delete';

  @override
  String get shoppingCategoryOther => 'Other';

  @override
  String get recipeTitle => 'Recipes';

  @override
  String get recipeTabDiscover => 'Discover';

  @override
  String get recipeTabFavorites => 'Favorites';

  @override
  String get recipeSearchHint => 'Search for a recipe...';

  @override
  String get recipeNoResults => 'No recipes found.';

  @override
  String get recipeIngredientsAddedTitle => 'Ingredients added!';

  @override
  String get recipeIngredientsAddedMessage =>
      'Ingredients have been added to your shopping list. Do you want to see it now?';

  @override
  String get recipeDialogStay => 'Stay here';

  @override
  String get recipeDialogViewList => 'View list';

  @override
  String recipeAddError(String error) {
    return 'Error adding items: $error';
  }

  @override
  String get recipeMealTypeTitle => 'Which meal?';

  @override
  String get recipeMealTypeBreakfast => 'Breakfast ☕';

  @override
  String get recipeMealTypeLunch => 'Lunch ☀️';

  @override
  String get recipeMealTypeSnack => 'Snack 🍎';

  @override
  String get recipeMealTypeDinner => 'Dinner 🌙';

  @override
  String get recipeAddedToPlanning => 'Recipe added to planner!';

  @override
  String get recipeViewPlanning => 'View';

  @override
  String recipeError(String error) {
    return 'Error: $error';
  }

  @override
  String get recipeIngredientsTitle => 'Ingredients';

  @override
  String get recipeAddIngredientsBtn => 'Add to shopping list';

  @override
  String get recipeFilterTitle => 'Chef Preferences';

  @override
  String get recipeFilterMealType => 'Meal Type';

  @override
  String get recipeFilterDiet => 'Diet';

  @override
  String get recipeFilterDifficulty => 'Difficulty';

  @override
  String get recipeFilterGenerate => 'Generate';

  @override
  String get recipeFilterCancel => 'Cancel';

  @override
  String get settingsSubscriptionHeader => 'Subscription';

  @override
  String get settingsAboutHeader => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsEditProfileTitle => 'Edit Profile';

  @override
  String get settingsDisplayNameLabel => 'Display Name';

  @override
  String get settingsCancelBtn => 'Cancel';

  @override
  String get settingsSaveBtn => 'Save';

  @override
  String get settingsProfileUpdated => 'Profile updated!';

  @override
  String settingsErrorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get householdNameRequired => 'Household name is required';

  @override
  String get householdCodeRequired => 'Invitation code is required';

  @override
  String recipeMissingIngredientsCount(int count) {
    return 'Missing: $count';
  }

  @override
  String get mealPlannerIngredientsAddedMessage =>
      'Ingredients have been added to your shopping list.';

  @override
  String get mealPlannerNoIngredientsAddedTitle => 'No ingredients added';

  @override
  String get mealPlannerNoIngredientsAddedMessage =>
      'All necessary ingredients are already in your list or inventory.';

  @override
  String get ok => 'OK';

  @override
  String get cat_fruits_vegetables => 'Fruits & Vegetables';

  @override
  String get cat_bakery => 'Bakery';

  @override
  String get cat_dairy_eggs => 'Dairy & Eggs';

  @override
  String get cat_meat_fish => 'Meat & Fish';

  @override
  String get cat_frozen => 'Frozen';

  @override
  String get cat_pantry_salty => 'Salty Pantry';

  @override
  String get cat_pantry_sweet => 'Sweet Pantry';

  @override
  String get cat_beverages => 'Beverages';

  @override
  String get cat_baby => 'Baby';

  @override
  String get cat_pets => 'Pets';

  @override
  String get cat_other => 'Other';

  @override
  String get loc_fridge => 'Fridge';

  @override
  String get loc_freezer => 'Freezer';

  @override
  String get loc_pantry => 'Pantry';
}
