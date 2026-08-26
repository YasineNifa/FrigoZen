// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FrigoZen';

  @override
  String get inventoryTab => 'Inventaire';

  @override
  String get shoppingListTab => 'Les courses';

  @override
  String get favoritesTab => 'Favoris';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get scanReceipt => 'Scanner un ticket';

  @override
  String get db_milk => 'Lait';

  @override
  String get db_chicken => 'Poulet';

  @override
  String get db_apple => 'Pomme';

  @override
  String get db_tomato => 'Tomate';

  @override
  String get db_pasta => 'Pâtes';

  @override
  String get db_rice => 'Riz';

  @override
  String get authWelcomeBack => 'Bon retour !';

  @override
  String get authWelcome => 'Bienvenue sur FrigoZen';

  @override
  String get authLoginSubtitle => 'Connectez-vous pour gérer votre frigo.';

  @override
  String get authSignupSubtitle =>
      'Créez un compte pour commencer à économiser.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authLoginBtn => 'Se connecter';

  @override
  String get authSignupBtn => 'S\'inscrire';

  @override
  String get authNoAccount => 'Pas encore de compte ? ';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get authToLogin => 'Se connecter';

  @override
  String get authSuccess =>
      'Compte créé avec succès. Vous pouvez vous connecter.';

  @override
  String get authVerifyEmailSent =>
      'Un email de vérification a été envoyé. Veuillez vérifier votre boîte de réception.';

  @override
  String get authErrorGeneric =>
      'Une erreur est survenue, veuillez vérifier vos identifiants.';

  @override
  String get authErrorNoUser => 'Aucun utilisateur trouvé pour cet email.';

  @override
  String get authErrorWrongPass => 'Mot de passe incorrect.';

  @override
  String get authErrorEmailInUse => 'Cet email est déjà utilisé.';

  @override
  String get authErrorWeakPass => 'Le mot de passe est trop faible.';

  @override
  String get authFieldRequired => 'Ce champ est requis.';

  @override
  String get authInvalidEmail => 'Veuillez entrer un email valide.';

  @override
  String get authShortPassword =>
      'Le mot de passe doit faire plus de 6 caractères.';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authPasswordsDontMatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get verifyEmailTitle => 'Vérifiez votre email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Nous avons envoyé un lien de vérification à $email.';
  }

  @override
  String get verifyEmailBody =>
      'Ouvrez le lien pour activer votre compte, puis revenez ici pour continuer.';

  @override
  String get verifyEmailResend => 'Renvoyer l\'email';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Nouvel envoi possible dans $seconds s';
  }

  @override
  String get verifyEmailCheckBtn => 'J\'ai vérifié mon email';

  @override
  String get verifyEmailNotVerifiedYet =>
      'Votre email n\'est pas encore vérifié. Merci de cliquer sur le lien que nous vous avons envoyé.';

  @override
  String get verifyEmailSignOut => 'Se déconnecter';

  @override
  String get householdWelcome => 'Bienvenue chez vous !';

  @override
  String get householdSubtitle =>
      'Pour commencer, créez votre espace familial ou rejoignez-en un existant.';

  @override
  String get householdCreateTitle => 'Créer un nouvel espace';

  @override
  String get householdNameLabel => 'Nom de la maison (ex: Chez Nous)';

  @override
  String get householdCreateBtn => 'Créer';

  @override
  String get householdOr => 'OU';

  @override
  String get householdJoinTitle => 'Rejoindre un espace';

  @override
  String get householdCodeLabel => 'Code d\'invitation (ex: FZ-1234)';

  @override
  String get householdJoinBtn => 'Rejoindre';

  @override
  String get householdErrorNameRequired => 'Le nom est requis';

  @override
  String get householdErrorCodeRequired => 'Le code est requis';

  @override
  String get addItemTitle => 'Ajouter un produit';

  @override
  String get addItemNameLabel => 'Nom (ex: Lait)';

  @override
  String get addItemNameError => 'Veuillez entrer un nom.';

  @override
  String addItemQuantityLabel(int quantity) {
    return 'Quantité : $quantity';
  }

  @override
  String get addItemSaveBtn => 'Sauvegarder';

  @override
  String addItemError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get inventoryTitle => 'Mon Inventaire';

  @override
  String get inventoryTabAll => 'Tout';

  @override
  String get inventoryTabFridge => 'Frigo';

  @override
  String get inventoryTabPantry => 'Placard';

  @override
  String get inventoryTabFreezer => 'Congél.';

  @override
  String get inventorySearchHint => 'Rechercher un produit...';

  @override
  String get inventoryEmptyTitle => 'Votre inventaire est vide';

  @override
  String get inventoryEmptySubtitle => 'Appuyez sur + pour ajouter un produit.';

  @override
  String get suggestRecipeTooltip => 'Idée Recette';

  @override
  String get scanReceiptCamera => 'Scanner avec la caméra';

  @override
  String get scanReceiptGallery => 'Choisir depuis la galerie';

  @override
  String get scanManual => 'Ajouter manuellement';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingPage1Title => 'Arrêtez de jeter votre argent.';

  @override
  String get onboardingPage1Desc =>
      'FrigoZen vous aide à consommer vos aliments avant qu\'ils n\'expirent.';

  @override
  String get onboardingPage1Btn => 'Continuer';

  @override
  String get onboardingPage2Title => 'Sachez toujours quoi manger.';

  @override
  String get onboardingPage2Desc =>
      'Recevez des recettes simples basées sur ce que vous avez déjà dans votre frigo.';

  @override
  String get onboardingPage2Btn => 'Commencer';

  @override
  String get onboardingPage3Title => 'Des courses enfin intelligentes.';

  @override
  String get onboardingPage3Desc =>
      'Ne rachetez plus jamais en double. Scannez, c\'est ajouté, votre liste est à jour.';

  @override
  String get onboardingPage3Btn => 'Commencer l\'aventure';

  @override
  String get onboardingHaveAccount => 'J\'ai déjà un compte';

  @override
  String get paywallTitle => 'Passez à la vitesse supérieure';

  @override
  String get paywallSubtitle =>
      'Débloquez tout le potentiel de votre cuisine et économisez jusqu\'à 500€ par an.';

  @override
  String get paywallBenefit1Title => 'Scan de Tickets IA';

  @override
  String get paywallBenefit1Desc => 'Ajoutez vos courses en 2 secondes.';

  @override
  String get paywallBenefit2Title => 'Recettes Magiques';

  @override
  String get paywallBenefit2Desc => 'Génération illimitée avec photos.';

  @override
  String get paywallBenefit3Title => 'Alertes Anti-Gaspi';

  @override
  String get paywallBenefit3Desc =>
      'Soyez prévenu avant qu\'il soit trop tard.';

  @override
  String get paywallBenefit4Title => 'Scanner Santé';

  @override
  String get paywallBenefit4Desc => 'Nutri-Score et détails produits.';

  @override
  String get paywallBenefit5Title => 'Partage Familial';

  @override
  String get paywallBenefit5Desc => 'Invitez votre foyer.';

  @override
  String get paywallAnnual => 'Annuel';

  @override
  String get paywallMonthly => 'Mensuel';

  @override
  String get paywallSaveLabel => 'ÉCONOMISEZ 50%';

  @override
  String get paywallSubscribeBtn => 'S\'abonner maintenant';

  @override
  String get paywallRestoreBtn => 'Restaurer les achats';

  @override
  String get paywallLegalText =>
      'Sans engagement. Annulable à tout moment. En continuant, vous acceptez les CGU et la Politique de Confidentialité.';

  @override
  String get paywallSuccess => 'Bienvenue dans le club FrigoZen Pro ! 🌟';

  @override
  String get paywallError =>
      'Impossible de charger les offres. Veuillez réessayer plus tard.';

  @override
  String get favoritesTitle => 'Mon Carnet';

  @override
  String get favoritesEmptyTitle => 'Aucune recette favorite';

  @override
  String get favoritesEmptySubtitle =>
      'Sauvegardez les recettes que vous aimez pour les retrouver ici.';

  @override
  String get favoritesLockedTitle => 'Fonctionnalité Premium';

  @override
  String get favoritesLockedSubtitle =>
      'Passez à FrigoZen Pro pour sauvegarder vos recettes IA et créer votre livre de cuisine personnel.';

  @override
  String get favoritesUnlockBtn => 'Débloquer mon Carnet';

  @override
  String get favoritesUntitled => 'Recette sans titre';

  @override
  String get favoritesNoDesc => 'Pas de description.';

  @override
  String get recipeDetailUntitled => 'Recette sans titre';

  @override
  String get recipeDetailNoDesc => 'Pas de description disponible.';

  @override
  String get recipeDetailFridge => 'VOTRE FRIGO';

  @override
  String get recipeDetailToBuy => 'À ACHETER';

  @override
  String get recipeDetailPreparation => 'PRÉPARATION';

  @override
  String get recipeDetailSaved => 'Recette ajoutée aux Favoris ! ❤️';

  @override
  String get recipeDetailRemoved => 'Recette retirée des Favoris.';

  @override
  String recipeDetailError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccountInfo => 'Informations du compte';

  @override
  String get settingsNoEmail => 'Aucun email disponible';

  @override
  String get settingsManageSub => 'Gérer l\'abonnement';

  @override
  String get settingsUpgrade => 'Passer à FrigoZen Pro';

  @override
  String get settingsProMember => 'Vous êtes membre Pro.';

  @override
  String get settingsUnlockFeatures => 'Débloquez toutes les fonctionnalités.';

  @override
  String get settingsErrorOpen => 'Impossible d\'ouvrir les paramètres';

  @override
  String get settingsRestore => 'Restaurer les achats';

  @override
  String get settingsRestoreSuccess => 'Achats restaurés avec succès.';

  @override
  String settingsRestoreFail(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get settingsFamilyHeader => 'FAMILLE & FOYER';

  @override
  String get settingsDefaultHouse => 'Maison';

  @override
  String get settingsInviteMembers => 'Inviter des membres';

  @override
  String get settingsInvitePremiumHint =>
      'Passez Premium pour partager votre inventaire.';

  @override
  String get settingsInviteCodeLabel => 'Code d\'invitation :';

  @override
  String get settingsCodeCopied => 'Code copié !';

  @override
  String get settingsShareHint =>
      'Partagez ce code pour inviter votre famille.';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get shoppingTitle => 'Liste de courses';

  @override
  String get shoppingItemNoTitle => 'Article inconnu';

  @override
  String shoppingDuplicateAlert(String itemName) {
    return '💡 Attention ! Vous avez déjà \"$itemName\" dans votre inventaire !';
  }

  @override
  String get shoppingAddAnyway => 'Ajouter quand même';

  @override
  String shoppingErrorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String shoppingMovedSuccess(int count) {
    return '$count article(s) déplacé(s) vers l\'inventaire !';
  }

  @override
  String shoppingMoveError(String error) {
    return 'Erreur lors du déplacement : $error';
  }

  @override
  String get shoppingAddingBtn => 'Ajout en cours...';

  @override
  String shoppingMoveBtn(int count) {
    return 'Ranger $count article(s)';
  }

  @override
  String validationTitle(int count) {
    return 'Valider les articles ($count)';
  }

  @override
  String get validationCancelBtn => 'Annuler';

  @override
  String validationAddBtn(int count) {
    return 'Ajouter $count articles';
  }

  @override
  String validationSuccess(int count) {
    return '$count articles ajoutés à l\'inventaire !';
  }

  @override
  String validationError(String error) {
    return 'Erreur lors de l\'ajout : $error';
  }

  @override
  String get shoppingListEmptyTitle => 'Votre liste de courses est vide';

  @override
  String get shoppingListEmptySubtitle =>
      'Ajoutez un article ci-dessus pour commencer.';

  @override
  String get inputFieldHintText => 'Ajouter à la liste de courses';

  @override
  String editBatchesTitle(String itemName) {
    return 'Gérer les lots : $itemName';
  }

  @override
  String get editBatchesSubtitle =>
      'Cliquez sur le crayon pour modifier les détails d\'un lot.';

  @override
  String get editBatchesEmpty => 'Aucune information de date.';

  @override
  String get editBatchesExpiredPrefix => 'PÉRIMÉ LE';

  @override
  String get editBatchesExpiresPrefix => 'Expire le';

  @override
  String get editBatchesSuccess => 'Lot mis à jour avec succès ! ✅';

  @override
  String editBatchesError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get mealPlannerTitle => 'Mon Semainier';

  @override
  String get mealPlannerGenerateList => 'Générer la liste de courses';

  @override
  String get mealPlannerBreakfast => 'Petit-déjeuner ☕';

  @override
  String get mealPlannerLunch => 'Déjeuner ☀️';

  @override
  String get mealPlannerSnack => 'Encas 🍎';

  @override
  String get mealPlannerDinner => 'Dîner 🌙';

  @override
  String get mealPlannerAddMeal => 'Ajouter un repas';

  @override
  String get mealPlannerEditMeal => 'Modifier le repas';

  @override
  String get mealPlannerMealNameLabel => 'Nom du repas';

  @override
  String get mealPlannerMealNameHint => 'Ex: Pâtes carbo';

  @override
  String get mealPlannerIngredientsLabel =>
      'Ingrédients (séparés par des virgules)';

  @override
  String get mealPlannerIngredientsHint => 'Ex: Pâtes, Lardons, Crème, Oeufs';

  @override
  String get mealPlannerCancel => 'Annuler';

  @override
  String get mealPlannerModify => 'Modifier';

  @override
  String get mealPlannerAdd => 'Ajouter';

  @override
  String get mealPlannerAnalyzing =>
      'Analyse de l\'inventaire et génération de la liste... ⏳';

  @override
  String mealPlannerAddedIngredients(int count) {
    return '$count ingrédients ajoutés à la liste !';
  }

  @override
  String get mealPlannerViewList => 'VOIR';

  @override
  String get paywallBenefitSmartListTitle => 'Liste Intelligente';

  @override
  String get paywallBenefitSmartListDesc =>
      'Génération automatique et intelligente.';

  @override
  String get mealPlannerSmartListUpsell =>
      'Passez Pro pour la génération intelligente par IA !';

  @override
  String get mealPlannerGoPremium => 'Devenir Premium';

  @override
  String get paywallTermsButton => 'Conditions Générales';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get quickActionsTitle => 'Actions Rapides';

  @override
  String get scanActionLabel => 'Scanner';

  @override
  String get addActionLabel => 'Ajouter';

  @override
  String get mealPlannerCardTitle => 'Mon Semainier';

  @override
  String get mealPlannerCardSubtitle => 'Planifiez vos repas de la semaine';

  @override
  String get expiringSoonTitle => 'À Manger Vite !';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryToEat => 'À manger';

  @override
  String get summaryShopping => 'Courses';

  @override
  String get expiredLabel => 'Périmé';

  @override
  String get todayLabel => 'Aujourd\'hui';

  @override
  String daysLeftLabel(int days) {
    return 'J-$days';
  }

  @override
  String get statsTopCategories => 'Top Catégories';

  @override
  String get statsNutriScore => 'Qualité Nutritionnelle';

  @override
  String statsScoreLabel(String score) {
    return 'Score $score';
  }

  @override
  String get statsPremiumLabel => 'Statistiques Premium';

  @override
  String get statsUnlockBtn => 'Débloquer';

  @override
  String get statsStorageDistribution => 'Répartition par Lieu';

  @override
  String get statsFavoriteStores => 'Vos Magasins Préférés';

  @override
  String get inventoryEmpty => 'Votre inventaire est vide !';

  @override
  String errorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String get renameProductTitle => 'Renommer le produit';

  @override
  String get newNameLabel => 'Nouveau nom';

  @override
  String get cancelBtn => 'Annuler';

  @override
  String get saveBtn => 'Enregistrer';

  @override
  String get renameTooltip => 'Renommer';

  @override
  String addedOnDate(String date) {
    return 'Ajouté le $date';
  }

  @override
  String get editBatchTitle => 'Modifier le lot';

  @override
  String get specificNameLabel => 'Nom spécifique';

  @override
  String get specificNameHint => 'ex: Oeufs Bio';

  @override
  String get brandLabel => 'Marque';

  @override
  String get brandHint => 'ex: Bio Village';

  @override
  String get storeLabel => 'Magasin';

  @override
  String get storeHint => 'ex: Leclerc';

  @override
  String get nutriScoreLabel => 'Nutri-Score';

  @override
  String get nutriScoreUndefined => 'Non défini';

  @override
  String get expirationDateLabel => 'Date d\'expiration';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get searchNoResults => 'Aucun résultat trouvé';

  @override
  String get searchTryDifferent => 'Essayez un autre terme de recherche.';

  @override
  String get statusExpired => 'Périmé';

  @override
  String get statusExpiresToday => 'Périme aujourd\'hui';

  @override
  String get statusExpiresSoon => 'Périme bientôt';

  @override
  String statusExpiresInDays(int days) {
    return 'Périme dans $days jours';
  }

  @override
  String get statusFresh => 'Frais';

  @override
  String get scanBarcodeTitle => 'Scanner un code-barres';

  @override
  String get productUnknown => 'Produit inconnu';

  @override
  String productAdded(String name) {
    return '$name ajouté !';
  }

  @override
  String get productNotFoundOFF => 'Produit non trouvé dans Open Food Facts.';

  @override
  String serverErrorOFF(Object code) {
    return 'Erreur serveur OFF ($code)';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get shoppingItemAlreadyInStockTitle => 'Produit déjà en stock';

  @override
  String shoppingItemAlreadyInStockMessage(String itemName) {
    return 'Vous avez déjà \'$itemName\' dans votre inventaire. Voulez-vous l\'ajouter quand même à la liste de courses ?';
  }

  @override
  String get shoppingDialogNo => 'Non';

  @override
  String get shoppingDialogYesAdd => 'Oui, ajouter';

  @override
  String get shoppingFinishedTitle => 'Courses terminées ! 🎉';

  @override
  String get shoppingDialogStay => 'Rester ici';

  @override
  String get shoppingDialogViewInventory => 'Voir l\'inventaire';

  @override
  String get shoppingUncheckAllTooltip => 'Tout décocher';

  @override
  String get shoppingCheckAllTooltip => 'Tout cocher';

  @override
  String get shoppingDeleteAllTooltip => 'Tout supprimer';

  @override
  String get shoppingDeleteAllTitle => 'Tout supprimer ?';

  @override
  String get shoppingDeleteAllMessage =>
      'Voulez-vous vraiment vider votre liste de courses ? Cette action est irréversible.';

  @override
  String get shoppingDialogCancel => 'Annuler';

  @override
  String get shoppingDialogDelete => 'Supprimer';

  @override
  String get shoppingCategoryOther => 'Autres';

  @override
  String get recipeTitle => 'Recettes';

  @override
  String get recipeTabDiscover => 'Découvrir';

  @override
  String get recipeTabCatalog => 'Catalogue';

  @override
  String get recipeTabFavorites => 'Favoris';

  @override
  String get recipeSearchHint => 'Rechercher une recette...';

  @override
  String get recipeNoResults => 'Aucune recette trouvée.';

  @override
  String get recipeIngredientsAddedTitle => 'Ingrédients ajoutés !';

  @override
  String get recipeIngredientsAddedMessage =>
      'Les ingrédients ont été ajoutés à votre liste de courses. Voulez-vous la voir maintenant ?';

  @override
  String get recipeDialogStay => 'Rester ici';

  @override
  String get recipeDialogViewList => 'Voir la liste';

  @override
  String recipeAddError(String error) {
    return 'Erreur lors de l\'ajout : $error';
  }

  @override
  String get recipeMealTypeTitle => 'Quel repas ?';

  @override
  String get recipeMealTypeBreakfast => 'Petit-déjeuner ☕';

  @override
  String get recipeMealTypeLunch => 'Déjeuner ☀️';

  @override
  String get recipeMealTypeSnack => 'Encas 🍎';

  @override
  String get recipeMealTypeDinner => 'Dîner 🌙';

  @override
  String get recipeAddedToPlanning => 'Recette ajoutée au planning !';

  @override
  String get recipeViewPlanning => 'Voir';

  @override
  String recipeError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get recipeIngredientsTitle => 'Ingrédients';

  @override
  String get recipeAddIngredientsBtn => 'Ajouter à la liste de courses';

  @override
  String get recipeFilterTitle => 'Préférences du Chef';

  @override
  String get recipeFilterCancel => 'Annuler';

  @override
  String get settingsSubscriptionHeader => 'Abonnement';

  @override
  String get settingsAboutHeader => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsEditProfileTitle => 'Modifier le profil';

  @override
  String get settingsDisplayNameLabel => 'Nom d\'affichage';

  @override
  String get settingsCancelBtn => 'Annuler';

  @override
  String get settingsSaveBtn => 'Enregistrer';

  @override
  String get settingsProfileUpdated => 'Profil mis à jour !';

  @override
  String settingsErrorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String get householdNameRequired => 'Le nom du foyer est requis';

  @override
  String get householdCodeRequired => 'Le code d\'invitation est requis';

  @override
  String recipeMissingIngredientsCount(int count) {
    return 'Manquant : $count';
  }

  @override
  String get mealPlannerIngredientsAddedMessage =>
      'Les ingrédients ont été ajoutés à votre liste de courses.';

  @override
  String get mealPlannerNoIngredientsAddedTitle => 'Aucun ingrédient ajouté';

  @override
  String get mealPlannerNoIngredientsAddedMessage =>
      'Tous les ingrédients nécessaires sont déjà dans votre liste ou votre inventaire.';

  @override
  String get ok => 'OK';

  @override
  String get cat_fruits_vegetables => 'Fruits & Légumes';

  @override
  String get cat_bakery => 'Boulangerie';

  @override
  String get cat_dairy_eggs => 'Laiterie & Œufs';

  @override
  String get cat_meat_fish => 'Viandes & Poissons';

  @override
  String get cat_frozen => 'Surgelés';

  @override
  String get cat_pantry_salty => 'Épicerie salée';

  @override
  String get cat_pantry_sweet => 'Épicerie sucrée';

  @override
  String get cat_beverages => 'Boissons';

  @override
  String get cat_baby => 'Bébés';

  @override
  String get cat_pets => 'Animaux';

  @override
  String get cat_other => 'Autres';

  @override
  String get loc_fridge => 'Frigo';

  @override
  String get loc_freezer => 'Congélateur';

  @override
  String get loc_pantry => 'Placard';

  @override
  String get scanProTip =>
      'Astuce : Scannez le code-barres pour plus de détails (Nutri-Score, etc.) !';

  @override
  String get shoppingPrioritizeScanTitle => 'Vous avez le ticket ?';

  @override
  String get shoppingPrioritizeScanMessage =>
      'En tant que membre Premium, scannez votre ticket pour avoir plus de détails (Marque, Nutri-Score...).\n\nSi vous scannez le ticket, n\'ajoutez PAS ces articles manuellement pour éviter les doublons.';

  @override
  String get shoppingPrioritizeScanBtn => 'Scanner le ticket';

  @override
  String get shoppingPrioritizeManualBtn => 'Non, ajouter manuellement';

  @override
  String get scanAnalyzing => 'Analyse du ticket...';

  @override
  String get headerExpired => 'Périmé';

  @override
  String get headerUrgent => 'Urgent (≤ 3 jours)';

  @override
  String get headerThisWeek => 'Cette semaine';

  @override
  String get headerFresh => 'Frais';

  @override
  String get searchProductTitle => 'Rechercher un produit';

  @override
  String get searchProductHint => 'Nom du produit (ex: Nutella)';

  @override
  String get searchProductNoResults => 'Aucun résultat';

  @override
  String get searchProductEmpty => 'Tapez le nom d\'un produit...';

  @override
  String get defaultStoreName => 'Ajout Rapide';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get priceLabel => 'Prix';

  @override
  String get shoppingInventoryCheckDisabled => 'Inventaire ?';

  @override
  String get sortPriority => 'Priorité';

  @override
  String get sortCategory => 'Rayon';

  @override
  String get sortList => 'Liste';

  @override
  String get householdFullError => 'Ce foyer a atteint la limite de 5 membres.';

  @override
  String get settingsEditAvatar => 'Modifier l\'avatar';

  @override
  String get settingsSelectAvatar => 'Choisir un avatar';

  @override
  String get historyTitle => 'Activité';

  @override
  String activityAddedShopping(Object item, Object user) {
    return '$user a ajouté $item à la liste';
  }

  @override
  String activityBought(Object item, Object user) {
    return '$user a acheté $item';
  }

  @override
  String activityConsumed(Object item, Object user) {
    return '$user a consommé $item';
  }

  @override
  String activityTrashed(Object item, Object user) {
    return '$user a jeté $item';
  }

  @override
  String get activityEmpty => 'Aucune activité récente';

  @override
  String get timeJustNow => 'À l\'instant';

  @override
  String timeMinutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String timeTodayAt(String time) {
    return '$time';
  }

  @override
  String timeDateAt(String date, String time) {
    return '$date $time';
  }

  @override
  String get recipeTabAI => 'Chef IA';

  @override
  String get recipeAITitle => 'Cuisinez avec votre frigo';

  @override
  String get recipeAIDesc =>
      'Laissez notre Chef IA générer des recettes délicieuses basées sur votre inventaire.';

  @override
  String get recipeAIBtn => 'Générer des recettes';

  @override
  String get settingsFreeTrial => 'Essai gratuit';

  @override
  String trialDaysLeft(int days) {
    return 'Essai : $days jours restants';
  }

  @override
  String get trialEndedSubtitle =>
      'Votre essai gratuit est terminé. Passez à Pro pour garder toutes les fonctionnalités.';

  @override
  String get trialReminderTitle => 'Votre essai FrigoZen se termine bientôt';

  @override
  String trialReminderBody(int days) {
    return 'Il vous reste $days jours d\'essai gratuit. Passez à Pro pour garder toutes les fonctionnalités.';
  }

  @override
  String get paywallTrialEndedSubtitle =>
      'Votre essai gratuit de 15 jours est terminé. Abonnez-vous pour continuer à utiliser les fonctionnalités Pro.';
}
