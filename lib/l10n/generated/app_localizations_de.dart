// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FrigoZen';

  @override
  String get inventoryTab => 'Inventar';

  @override
  String get shoppingListTab => 'Einkaufsliste';

  @override
  String get favoritesTab => 'Favoriten';

  @override
  String get settingsTab => 'Einstellungen';

  @override
  String get scanReceipt => 'Beleg scannen';

  @override
  String get db_milk => 'Milch';

  @override
  String get db_chicken => 'Hähnchen';

  @override
  String get db_apple => 'Apfel';

  @override
  String get db_tomato => 'Tomate';

  @override
  String get db_pasta => 'Nudeln';

  @override
  String get db_rice => 'Reis';

  @override
  String get authWelcomeBack => 'Willkommen zurück';

  @override
  String get authWelcome => 'Willkommen bei FrigoZen';

  @override
  String get authLoginSubtitle =>
      'Melden Sie sich an, um Ihren Kühlschrank zu verwalten.';

  @override
  String get authSignupSubtitle => 'Erstellen Sie ein Konto, um zu sparen.';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authLoginBtn => 'Anmelden';

  @override
  String get authSignupBtn => 'Registrieren';

  @override
  String get authNoAccount => 'Kein Konto? ';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authHaveAccount => 'Haben Sie bereits ein Konto? ';

  @override
  String get authToLogin => 'Anmelden';

  @override
  String get authSuccess =>
      'Konto erfolgreich erstellt. Sie können sich jetzt anmelden.';

  @override
  String get authVerifyEmailSent =>
      'Eine Bestätigungs-E-Mail wurde gesendet. Bitte überprüfen Sie Ihren Posteingang.';

  @override
  String get authErrorGeneric =>
      'Ein Fehler ist aufgetreten, bitte überprüfen Sie Ihre Anmeldedaten.';

  @override
  String get authErrorNoUser => 'Kein Benutzer für diese E-Mail gefunden.';

  @override
  String get authErrorWrongPass => 'Falsches Passwort.';

  @override
  String get authErrorEmailInUse => 'Diese E-Mail wird bereits verwendet.';

  @override
  String get authErrorWeakPass => 'Das Passwort ist zu schwach.';

  @override
  String get authFieldRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get authInvalidEmail => 'Bitte geben Sie eine gültige E-Mail ein.';

  @override
  String get authShortPassword =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get authConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get authPasswordsDontMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get verifyEmailTitle => 'Bestätigen Sie Ihre E-Mail';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Wir haben einen Bestätigungslink an $email gesendet.';
  }

  @override
  String get verifyEmailBody =>
      'Öffnen Sie den Link, um Ihr Konto zu aktivieren, und kehren Sie dann hierher zurück.';

  @override
  String get verifyEmailResend => 'E-Mail erneut senden';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Erneutes Senden möglich in $seconds s';
  }

  @override
  String get verifyEmailCheckBtn => 'Ich habe meine E-Mail bestätigt';

  @override
  String get verifyEmailNotVerifiedYet =>
      'Ihre E-Mail ist noch nicht bestätigt. Bitte klicken Sie auf den gesendeten Link.';

  @override
  String get verifyEmailSignOut => 'Abmelden';

  @override
  String get householdWelcome => 'Willkommen zu Hause!';

  @override
  String get householdSubtitle =>
      'Erstellen Sie Ihren Familienbereich oder treten Sie einem bestehenden bei.';

  @override
  String get householdCreateTitle => 'Neuen Bereich erstellen';

  @override
  String get householdNameLabel => 'Haushaltsname (z.B. Mein Zuhause)';

  @override
  String get householdCreateBtn => 'Erstellen';

  @override
  String get householdOr => 'ODER';

  @override
  String get householdJoinTitle => 'Bereich beitreten';

  @override
  String get householdCodeLabel => 'Einladungscode (z.B. FZ-1234)';

  @override
  String get householdJoinBtn => 'Beitreten';

  @override
  String get householdErrorNameRequired => 'Name ist erforderlich';

  @override
  String get householdErrorCodeRequired => 'Code ist erforderlich';

  @override
  String get addItemTitle => 'Neues Produkt hinzufügen';

  @override
  String get addItemNameLabel => 'Name (z.B. Milch)';

  @override
  String get addItemNameError => 'Bitte geben Sie einen Namen ein.';

  @override
  String addItemQuantityLabel(int quantity) {
    return 'Menge : $quantity';
  }

  @override
  String get addItemSaveBtn => 'Speichern';

  @override
  String addItemError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get inventoryTitle => 'Mein Inventar';

  @override
  String get inventoryTabAll => 'Alles';

  @override
  String get inventoryTabFridge => 'Kühlschrank';

  @override
  String get inventoryTabPantry => 'Vorratskammer';

  @override
  String get inventoryTabFreezer => 'Gefrierschrank';

  @override
  String get inventorySearchHint => 'Produkt suchen...';

  @override
  String get inventoryEmptyTitle => 'Ihr Inventar ist leer';

  @override
  String get inventoryEmptySubtitle =>
      'Tippen Sie auf +, um ein Produkt hinzuzufügen.';

  @override
  String get suggestRecipeTooltip => 'Rezeptvorschlag';

  @override
  String get scanReceiptCamera => 'Beleg scannen (Kamera)';

  @override
  String get scanReceiptGallery => 'Aus Galerie auswählen';

  @override
  String get scanManual => 'Manuell hinzufügen';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingPage1Title => 'Hören Sie auf, Geld zu verschwenden.';

  @override
  String get onboardingPage1Desc =>
      'FrigoZen hilft Ihnen, Ihre Lebensmittel zu verbrauchen, bevor sie ablaufen.';

  @override
  String get onboardingPage1Btn => 'Weiter';

  @override
  String get onboardingPage2Title => 'Wissen, was man essen soll.';

  @override
  String get onboardingPage2Desc =>
      'Erhalten Sie einfache Rezepte basierend auf dem, was Sie bereits im Kühlschrank haben.';

  @override
  String get onboardingPage2Btn => 'Starten';

  @override
  String get onboardingPage3Title => 'Endlich intelligent einkaufen.';

  @override
  String get onboardingPage3Desc =>
      'Kaufen Sie nie wieder doppelt. Scannen, hinzufügen, und Ihre Liste ist aktuell.';

  @override
  String get onboardingPage3Btn => 'Abenteuer beginnen';

  @override
  String get onboardingHaveAccount => 'Ich habe bereits ein Konto';

  @override
  String get paywallTitle => 'Bringen Sie es auf die nächste Stufe';

  @override
  String get paywallSubtitle =>
      'Nutzen Sie das volle Potenzial Ihrer Küche und sparen Sie bis zu 500€ pro Jahr.';

  @override
  String get paywallBenefit1Title => 'KI-Belegscan';

  @override
  String get paywallBenefit1Desc =>
      'Fügen Sie Ihre Einkäufe in 2 Sekunden hinzu.';

  @override
  String get paywallBenefit2Title => 'Magische Rezepte';

  @override
  String get paywallBenefit2Desc => 'Unbegrenzte Generierung mit Fotos.';

  @override
  String get paywallBenefit3Title => 'Anti-Verschwendungs-Warnungen';

  @override
  String get paywallBenefit3Desc => 'Werden Sie gewarnt, bevor es zu spät ist.';

  @override
  String get paywallBenefit4Title => 'Gesundheitsscanner';

  @override
  String get paywallBenefit4Desc => 'Nutri-Score und Produktdetails.';

  @override
  String get paywallBenefit5Title => 'Familienfreigabe';

  @override
  String get paywallBenefit5Desc => 'Laden Sie Ihren Haushalt ein.';

  @override
  String get paywallAnnual => 'Jährlich';

  @override
  String get paywallMonthly => 'Monatlich';

  @override
  String get paywallSaveLabel => 'SPAREN SIE 50%';

  @override
  String get paywallSubscribeBtn => 'Jetzt abonnieren';

  @override
  String get paywallRestoreBtn => 'Käufe wiederherstellen';

  @override
  String get paywallLegalText =>
      'Keine Bindung. Jederzeit kündbar. Durch Fortfahren akzeptieren Sie die AGB und Datenschutzrichtlinie.';

  @override
  String get paywallSuccess => 'Willkommen im FrigoZen Pro Club! 🌟';

  @override
  String get paywallError =>
      'Angebote konnten nicht geladen werden. Bitte versuchen Sie es später erneut.';

  @override
  String get favoritesTitle => 'Mein Kochbuch';

  @override
  String get favoritesEmptyTitle => 'Noch keine Lieblingsrezepte';

  @override
  String get favoritesEmptySubtitle =>
      'Speichern Sie Rezepte, die Sie mögen, um sie hier zu finden.';

  @override
  String get favoritesLockedTitle => 'Premium-Funktion';

  @override
  String get favoritesLockedSubtitle =>
      'Wechseln Sie zu FrigoZen Pro, um Ihre KI-Rezepte zu speichern und Ihr persönliches Kochbuch zu erstellen.';

  @override
  String get favoritesUnlockBtn => 'Kochbuch freischalten';

  @override
  String get favoritesUntitled => 'Unbenanntes Rezept';

  @override
  String get favoritesNoDesc => 'Keine Beschreibung.';

  @override
  String get recipeDetailUntitled => 'Unbenanntes Rezept';

  @override
  String get recipeDetailNoDesc => 'Keine Beschreibung verfügbar.';

  @override
  String get recipeDetailFridge => 'IHR KÜHLSCHRANK';

  @override
  String get recipeDetailToBuy => 'ZU KAUFEN';

  @override
  String get recipeDetailPreparation => 'ZUBEREITUNG';

  @override
  String get recipeDetailSaved => 'Rezept zu Favoriten hinzugefügt! ❤️';

  @override
  String get recipeDetailRemoved => 'Rezept aus Favoriten entfernt.';

  @override
  String recipeDetailError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAccountInfo => 'Kontoinformationen';

  @override
  String get settingsNoEmail => 'Keine E-Mail verfügbar';

  @override
  String get settingsManageSub => 'Abonnement verwalten';

  @override
  String get settingsUpgrade => 'Auf FrigoZen Pro upgraden';

  @override
  String get settingsProMember => 'Sie sind Pro-Mitglied.';

  @override
  String get settingsUnlockFeatures => 'Alle Funktionen freischalten.';

  @override
  String get settingsErrorOpen => 'Einstellungen konnten nicht geöffnet werden';

  @override
  String get settingsRestore => 'Käufe wiederherstellen';

  @override
  String get settingsRestoreSuccess => 'Käufe erfolgreich wiederhergestellt.';

  @override
  String settingsRestoreFail(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get settingsFamilyHeader => 'FAMILIE & HAUSHALT';

  @override
  String get settingsDefaultHouse => 'Zuhause';

  @override
  String get settingsInviteMembers => 'Mitglieder einladen';

  @override
  String get settingsInvitePremiumHint =>
      'Werden Sie Premium, um Ihr Inventar zu teilen.';

  @override
  String get settingsInviteCodeLabel => 'Einladungscode:';

  @override
  String get settingsCodeCopied => 'Code kopiert!';

  @override
  String get settingsShareHint =>
      'Teilen Sie diesen Code, um Ihre Familie einzuladen.';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get shoppingTitle => 'Einkaufsliste';

  @override
  String get shoppingItemNoTitle => 'Unbekannter Artikel';

  @override
  String shoppingDuplicateAlert(String itemName) {
    return '💡 Achtung! Sie haben \"$itemName\" bereits in Ihrem Inventar!';
  }

  @override
  String get shoppingAddAnyway => 'Trotzdem hinzufügen';

  @override
  String shoppingErrorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String shoppingMovedSuccess(int count) {
    return '$count Artikel erfolgreich ins Inventar verschoben!';
  }

  @override
  String shoppingMoveError(String error) {
    return 'Fehler beim Verschieben: $error';
  }

  @override
  String get shoppingAddingBtn => 'Hinzufügen...';

  @override
  String shoppingMoveBtn(int count) {
    return '$count Artikel ins Inventar räumen';
  }

  @override
  String validationTitle(int count) {
    return 'Artikel validieren ($count)';
  }

  @override
  String get validationCancelBtn => 'Abbrechen';

  @override
  String validationAddBtn(int count) {
    return '$count Artikel hinzufügen';
  }

  @override
  String validationSuccess(int count) {
    return '$count Artikel zum Inventar hinzugefügt!';
  }

  @override
  String validationError(String error) {
    return 'Fehler beim Hinzufügen: $error';
  }

  @override
  String get shoppingListEmptyTitle => 'Ihre Einkaufsliste ist leer';

  @override
  String get shoppingListEmptySubtitle =>
      'Fügen Sie oben einen Artikel hinzu, um zu beginnen.';

  @override
  String get inputFieldHintText => 'Zur Einkaufsliste hinzufügen';

  @override
  String editBatchesTitle(String itemName) {
    return 'Daten verwalten: $itemName';
  }

  @override
  String get editBatchesSubtitle =>
      'Klicken Sie auf den Stift, um ein Datum zu ändern.';

  @override
  String get editBatchesEmpty => 'Keine Datumsangaben.';

  @override
  String get editBatchesExpiredPrefix => 'ABGELAUFEN AM';

  @override
  String get editBatchesExpiresPrefix => 'Läuft ab am';

  @override
  String get editBatchesSuccess => 'Datum erfolgreich aktualisiert! ✅';

  @override
  String editBatchesError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get mealPlannerTitle => 'Mein Essensplaner';

  @override
  String get mealPlannerGenerateList => 'Einkaufsliste erstellen';

  @override
  String get mealPlannerBreakfast => 'Frühstück ☕';

  @override
  String get mealPlannerLunch => 'Mittagessen ☀️';

  @override
  String get mealPlannerSnack => 'Snack 🍎';

  @override
  String get mealPlannerDinner => 'Abendessen 🌙';

  @override
  String get mealPlannerAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get mealPlannerEditMeal => 'Mahlzeit bearbeiten';

  @override
  String get mealPlannerMealNameLabel => 'Name der Mahlzeit';

  @override
  String get mealPlannerMealNameHint => 'Bsp: Pasta Carbonara';

  @override
  String get mealPlannerIngredientsLabel => 'Zutaten (durch Kommas getrennt)';

  @override
  String get mealPlannerIngredientsHint => 'Bsp: Nudeln, Speck, Sahne, Eier';

  @override
  String get mealPlannerCancel => 'Abbrechen';

  @override
  String get mealPlannerModify => 'Ändern';

  @override
  String get mealPlannerAdd => 'Hinzufügen';

  @override
  String get mealPlannerAnalyzing =>
      'Inventar analysieren und Liste erstellen... ⏳';

  @override
  String mealPlannerAddedIngredients(int count) {
    return '$count Zutaten zur Liste hinzugefügt!';
  }

  @override
  String get mealPlannerViewList => 'ANSEHEN';

  @override
  String get paywallBenefitSmartListTitle => 'Intelligente Liste';

  @override
  String get paywallBenefitSmartListDesc =>
      'Automatische und intelligente Erstellung.';

  @override
  String get mealPlannerSmartListUpsell =>
      'Wechseln Sie zu Pro für intelligente KI-Generierung!';

  @override
  String get mealPlannerGoPremium => 'Premium werden';

  @override
  String get paywallTermsButton => 'AGB';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get quickActionsTitle => 'Schnellaktionen';

  @override
  String get scanActionLabel => 'Scannen';

  @override
  String get addActionLabel => 'Hinzufügen';

  @override
  String get mealPlannerCardTitle => 'Mein Wochenplan';

  @override
  String get mealPlannerCardSubtitle => 'Planen Sie Ihre Wochenmahlzeiten';

  @override
  String get expiringSoonTitle => 'Bald essen!';

  @override
  String get summaryTotal => 'Gesamt';

  @override
  String get summaryToEat => 'Zu essen';

  @override
  String get summaryShopping => 'Einkaufen';

  @override
  String get expiredLabel => 'Abgelaufen';

  @override
  String get todayLabel => 'Heute';

  @override
  String daysLeftLabel(int days) {
    return 'T-$days';
  }

  @override
  String get statsTopCategories => 'Top Kategorien';

  @override
  String get statsNutriScore => 'Ernährungsqualität';

  @override
  String statsScoreLabel(String score) {
    return 'Note $score';
  }

  @override
  String get statsPremiumLabel => 'Premium-Statistiken';

  @override
  String get statsUnlockBtn => 'Freischalten';

  @override
  String get statsStorageDistribution => 'Verteilung nach Lagerort';

  @override
  String get statsFavoriteStores => 'Ihre Lieblingsgeschäfte';

  @override
  String get inventoryEmpty => 'Ihr Inventar ist leer!';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get renameProductTitle => 'Produkt umbenennen';

  @override
  String get newNameLabel => 'Neuer Name';

  @override
  String get cancelBtn => 'Abbrechen';

  @override
  String get saveBtn => 'Speichern';

  @override
  String get renameTooltip => 'Umbenennen';

  @override
  String addedOnDate(String date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String get editBatchTitle => 'Charge bearbeiten';

  @override
  String get specificNameLabel => 'Spezifischer Name';

  @override
  String get specificNameHint => 'z.B. Bio-Eier';

  @override
  String get brandLabel => 'Marke';

  @override
  String get brandHint => 'z.B. Bio Village';

  @override
  String get storeLabel => 'Geschäft';

  @override
  String get storeHint => 'z.B. Aldi';

  @override
  String get nutriScoreLabel => 'Nutri-Score';

  @override
  String get nutriScoreUndefined => 'Nicht definiert';

  @override
  String get expirationDateLabel => 'Ablaufdatum';

  @override
  String get quantityLabel => 'Menge';

  @override
  String get searchNoResults => 'Keine Ergebnisse gefunden';

  @override
  String get searchTryDifferent => 'Versuchen Sie einen anderen Suchbegriff.';

  @override
  String get statusExpired => 'Abgelaufen';

  @override
  String get statusExpiresToday => 'Läuft heute ab';

  @override
  String get statusExpiresSoon => 'Läuft bald ab';

  @override
  String statusExpiresInDays(int days) {
    return 'Läuft in $days Tagen ab';
  }

  @override
  String get statusFresh => 'Frisch';

  @override
  String get scanBarcodeTitle => 'Barcode scannen';

  @override
  String get productUnknown => 'Unbekanntes Produkt';

  @override
  String productAdded(String name) {
    return '$name hinzugefügt!';
  }

  @override
  String get productNotFoundOFF => 'Produkt nicht in Open Food Facts gefunden.';

  @override
  String serverErrorOFF(Object code) {
    return 'OFF Serverfehler ($code)';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get shoppingItemAlreadyInStockTitle => 'Artikel bereits vorrätig';

  @override
  String shoppingItemAlreadyInStockMessage(String itemName) {
    return 'Sie haben \'$itemName\' bereits in Ihrem Inventar. Möchten Sie ihn trotzdem zur Einkaufsliste hinzufügen?';
  }

  @override
  String get shoppingDialogNo => 'Nein';

  @override
  String get shoppingDialogYesAdd => 'Ja, hinzufügen';

  @override
  String get shoppingFinishedTitle => 'Einkauf erledigt! 🎉';

  @override
  String get shoppingDialogStay => 'Hier bleiben';

  @override
  String get shoppingDialogViewInventory => 'Inventar ansehen';

  @override
  String get shoppingUncheckAllTooltip => 'Alle abwählen';

  @override
  String get shoppingCheckAllTooltip => 'Alle auswählen';

  @override
  String get shoppingDeleteAllTooltip => 'Alle löschen';

  @override
  String get shoppingDeleteAllTitle => 'Alle löschen?';

  @override
  String get shoppingDeleteAllMessage =>
      'Möchten Sie wirklich Ihre Einkaufsliste leeren? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get shoppingDialogCancel => 'Abbrechen';

  @override
  String get shoppingDialogDelete => 'Löschen';

  @override
  String get shoppingCategoryOther => 'Sonstiges';

  @override
  String get recipeTitle => 'Rezepte';

  @override
  String get recipeTabDiscover => 'Entdecken';

  @override
  String get recipeTabCatalog => 'Katalog';

  @override
  String get recipeTabFavorites => 'Favoriten';

  @override
  String get recipeSearchHint => 'Rezept suchen...';

  @override
  String get recipeNoResults => 'Keine Rezepte gefunden.';

  @override
  String get recipeIngredientsAddedTitle => 'Zutaten hinzugefügt!';

  @override
  String get recipeIngredientsAddedMessage =>
      'Zutaten wurden Ihrer Einkaufsliste hinzugefügt. Möchten Sie sie jetzt sehen?';

  @override
  String get recipeDialogStay => 'Hier bleiben';

  @override
  String get recipeDialogViewList => 'Liste ansehen';

  @override
  String recipeAddError(String error) {
    return 'Fehler beim Hinzufügen: $error';
  }

  @override
  String get recipeMealTypeTitle => 'Welche Mahlzeit?';

  @override
  String get recipeMealTypeBreakfast => 'Frühstück ☕';

  @override
  String get recipeMealTypeLunch => 'Mittagessen ☀️';

  @override
  String get recipeMealTypeSnack => 'Snack 🍎';

  @override
  String get recipeMealTypeDinner => 'Abendessen 🌙';

  @override
  String get recipeAddedToPlanning => 'Rezept zum Planer hinzugefügt!';

  @override
  String get recipeViewPlanning => 'Ansehen';

  @override
  String recipeError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get recipeIngredientsTitle => 'Zutaten';

  @override
  String get recipeAddIngredientsBtn => 'Zur Einkaufsliste';

  @override
  String get recipeFilterTitle => 'Chef-Präferenzen';

  @override
  String get recipeFilterCancel => 'Abbrechen';

  @override
  String get settingsSubscriptionHeader => 'Abonnement';

  @override
  String get settingsAboutHeader => 'Über';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingsTermsOfService => 'Nutzungsbedingungen';

  @override
  String get settingsEditProfileTitle => 'Profil bearbeiten';

  @override
  String get settingsDisplayNameLabel => 'Anzeigename';

  @override
  String get settingsCancelBtn => 'Abbrechen';

  @override
  String get settingsSaveBtn => 'Speichern';

  @override
  String get settingsProfileUpdated => 'Profil aktualisiert!';

  @override
  String settingsErrorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get householdNameRequired => 'Haushaltsname ist erforderlich';

  @override
  String get householdCodeRequired => 'Einladungscode ist erforderlich';

  @override
  String recipeMissingIngredientsCount(int count) {
    return 'Fehlend: $count';
  }

  @override
  String get mealPlannerIngredientsAddedMessage =>
      'Zutaten wurden Ihrer Einkaufsliste hinzugefügt.';

  @override
  String get mealPlannerNoIngredientsAddedTitle => 'Keine Zutaten hinzugefügt';

  @override
  String get mealPlannerNoIngredientsAddedMessage =>
      'Alle notwendigen Zutaten sind bereits in Ihrer Liste oder Ihrem Inventar.';

  @override
  String get ok => 'OK';

  @override
  String get cat_fruits_vegetables => 'Obst & Gemüse';

  @override
  String get cat_bakery => 'Bäckerei';

  @override
  String get cat_dairy_eggs => 'Milch & Eier';

  @override
  String get cat_meat_fish => 'Fleisch & Fisch';

  @override
  String get cat_frozen => 'Tiefkühl';

  @override
  String get cat_pantry_salty => 'Salzige Vorratskammer';

  @override
  String get cat_pantry_sweet => 'Süße Vorratskammer';

  @override
  String get cat_beverages => 'Getränke';

  @override
  String get cat_baby => 'Baby';

  @override
  String get cat_pets => 'Haustiere';

  @override
  String get cat_other => 'Sonstiges';

  @override
  String get loc_fridge => 'Kühlschrank';

  @override
  String get loc_freezer => 'Gefrierschrank';

  @override
  String get loc_pantry => 'Vorratskammer';

  @override
  String get scanProTip =>
      'Tipp: Scannen Sie den Barcode für weitere Details (Nutri-Score usw.)!';

  @override
  String get shoppingPrioritizeScanTitle => 'Haben Sie den Beleg?';

  @override
  String get shoppingPrioritizeScanMessage =>
      'Als Premium-Mitglied können Sie Ihren Beleg scannen, um Artikel mit mehr Details (Marke, Nutri-Score...) hinzuzufügen.\n\nWenn Sie den Beleg scannen, fügen Sie diese Artikel NICHT manuell hinzu, um Duplikate zu vermeiden.';

  @override
  String get shoppingPrioritizeScanBtn => 'Beleg scannen';

  @override
  String get shoppingPrioritizeManualBtn => 'Nein, manuell hinzufügen';

  @override
  String get scanAnalyzing => 'Beleg wird analysiert...';

  @override
  String get headerExpired => 'Abgelaufen';

  @override
  String get headerUrgent => 'Dringend (≤ 3 Tage)';

  @override
  String get headerThisWeek => 'Diese Woche';

  @override
  String get headerFresh => 'Frisch';

  @override
  String get searchProductTitle => 'Produkt suchen';

  @override
  String get searchProductHint => 'Produktname (z.B. Nutella)';

  @override
  String get searchProductNoResults => 'Keine Ergebnisse';

  @override
  String get searchProductEmpty => 'Geben Sie einen Produktnamen ein...';

  @override
  String get defaultStoreName => 'Schnell hinzufügen';

  @override
  String get defaultUserName => 'Benutzer';

  @override
  String get priceLabel => 'Preis';

  @override
  String get shoppingInventoryCheckDisabled => 'Inventar ?';

  @override
  String get sortPriority => 'Priorität';

  @override
  String get sortCategory => 'Kategorie';

  @override
  String get sortList => 'Liste';

  @override
  String get householdFullError =>
      'Dieser Haushalt hat das Limit von 5 Mitgliedern erreicht.';

  @override
  String get settingsEditAvatar => 'Avatar bearbeiten';

  @override
  String get settingsSelectAvatar => 'Avatar auswählen';

  @override
  String get historyTitle => 'Aktivität';

  @override
  String activityAddedShopping(Object item, Object user) {
    return '$user hat $item zur Liste hinzugefügt';
  }

  @override
  String activityBought(Object item, Object user) {
    return '$user hat $item gekauft';
  }

  @override
  String activityConsumed(Object item, Object user) {
    return '$user hat $item konsumiert';
  }

  @override
  String activityTrashed(Object item, Object user) {
    return '$user hat $item weggeworfen';
  }

  @override
  String get activityEmpty => 'Keine kürzlichen Aktivitäten';

  @override
  String get timeJustNow => 'Gerade eben';

  @override
  String timeMinutesAgo(int minutes) {
    return 'Vor $minutes Min.';
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
  String get recipeTabAI => 'KI-Chef';

  @override
  String get recipeAITitle => 'Kochen mit dem Kühlschrank';

  @override
  String get recipeAIDesc =>
      'Lassen Sie unseren KI-Chef köstliche Rezepte basierend auf Ihrem Inventar generieren.';

  @override
  String get recipeAIBtn => 'Rezepte generieren';
}
