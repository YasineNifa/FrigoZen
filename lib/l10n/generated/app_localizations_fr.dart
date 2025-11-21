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
  String get householdWelcome => 'Welcome home!';

  @override
  String get householdSubtitle =>
      'To begin, create your family space or join an existing one.';

  @override
  String get householdCreateTitle => 'Create a new space';

  @override
  String get householdNameLabel => 'Household Name (e.g. My Home)';

  @override
  String get householdCreateBtn => 'Create';

  @override
  String get householdOr => 'OR';

  @override
  String get householdJoinTitle => 'Join existing space';

  @override
  String get householdCodeLabel => 'Invitation Code (e.g. FZ-1234)';

  @override
  String get householdJoinBtn => 'Join';

  @override
  String get householdErrorNameRequired => 'Name is required';

  @override
  String get householdErrorCodeRequired => 'Code is required';

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
  String get recipeSuggestionTitle => 'Idées Recettes';

  @override
  String get recipeSuggestionEmpty =>
      'Aucune recette trouvée pour cette combinaison. :(';

  @override
  String get recipeSuggestionUntitled => 'Recette sans titre';

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
}
