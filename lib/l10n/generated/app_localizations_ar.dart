// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'FrigoZen';

  @override
  String get inventoryTab => 'المخزون';

  @override
  String get shoppingListTab => 'قائمة التسوق';

  @override
  String get favoritesTab => 'المفضلة';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get scanReceipt => 'مسح الإيصال';

  @override
  String get db_milk => 'حليب';

  @override
  String get db_chicken => 'دجاج';

  @override
  String get db_apple => 'تفاح';

  @override
  String get db_tomato => 'طماطم';

  @override
  String get db_pasta => 'معكرونة';

  @override
  String get db_rice => 'أرز';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك!';

  @override
  String get authWelcome => 'مرحبًا بك في FrigoZen';

  @override
  String get authLoginSubtitle => 'سجل الدخول لإدارة ثلاجتك.';

  @override
  String get authSignupSubtitle => 'أنشئ حسابًا لتبدأ التوفير.';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authLoginBtn => 'تسجيل الدخول';

  @override
  String get authSignupBtn => 'اشتراك';

  @override
  String get authNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get authToLogin => 'تسجيل الدخول';

  @override
  String get authSuccess => 'تم إنشاء الحساب بنجاح. يمكنك تسجيل الدخول الآن.';

  @override
  String get authVerifyEmailSent =>
      'تم إرسال بريد إلكتروني للتحقق. يرجى التحقق من صندوق الوارد الخاص بك.';

  @override
  String get authErrorGeneric =>
      'حدث خطأ، يرجى التحقق من بيانات الاعتماد الخاصة بك.';

  @override
  String get authErrorNoUser =>
      'لم يتم العثور على مستخدم لهذا البريد الإلكتروني.';

  @override
  String get authErrorWrongPass => 'كلمة المرور غير صحيحة.';

  @override
  String get authErrorEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get authErrorWeakPass => 'كلمة المرور ضعيفة جدًا.';

  @override
  String get authFieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get authInvalidEmail => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get authShortPassword =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get householdWelcome => 'مرحبًا بك في منزلك!';

  @override
  String get householdSubtitle =>
      'للبدء، أنشئ مساحتك العائلية أو انضم إلى مساحة موجودة.';

  @override
  String get householdCreateTitle => 'إنشاء مساحة جديدة';

  @override
  String get householdNameLabel => 'اسم المنزل (مثال: منزلي)';

  @override
  String get householdCreateBtn => 'إنشاء';

  @override
  String get householdOr => 'أو';

  @override
  String get householdJoinTitle => 'الانضمام إلى مساحة';

  @override
  String get householdCodeLabel => 'رمز الدعوة (مثال: FZ-1234)';

  @override
  String get householdJoinBtn => 'انضمام';

  @override
  String get householdErrorNameRequired => 'الاسم مطلوب';

  @override
  String get householdErrorCodeRequired => 'الرمز مطلوب';

  @override
  String get addItemTitle => 'إضافة منتج جديد';

  @override
  String get addItemNameLabel => 'الاسم (مثال: حليب)';

  @override
  String get addItemNameError => 'يرجى إدخال اسم.';

  @override
  String addItemQuantityLabel(int quantity) {
    return 'الكمية : $quantity';
  }

  @override
  String get addItemSaveBtn => 'حفظ';

  @override
  String addItemError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get inventoryTitle => 'مخزوني';

  @override
  String get inventoryTabAll => 'الكل';

  @override
  String get inventoryTabFridge => 'الثلاجة';

  @override
  String get inventoryTabPantry => 'المخزن';

  @override
  String get inventoryTabFreezer => 'المجمد';

  @override
  String get inventorySearchHint => 'البحث عن منتج...';

  @override
  String get inventoryEmptyTitle => 'مخزونك فارغ';

  @override
  String get inventoryEmptySubtitle => 'اضغط على + لإضافة منتج.';

  @override
  String get suggestRecipeTooltip => 'اقتراح وصفة';

  @override
  String get scanReceiptCamera => 'مسح الإيصال (الكاميرا)';

  @override
  String get scanReceiptGallery => 'اختر من المعرض';

  @override
  String get scanManual => 'إضافة يدوية';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingPage1Title => 'توقف عن إهدار أموالك.';

  @override
  String get onboardingPage1Desc =>
      'يساعدك FrigoZen على استهلاك طعامك قبل انتهاء صلاحيته.';

  @override
  String get onboardingPage1Btn => 'متابعة';

  @override
  String get onboardingPage2Title => 'اعرف دائمًا ماذا تأكل.';

  @override
  String get onboardingPage2Desc =>
      'احصل على وصفات بسيطة بناءً على ما لديك بالفعل في ثلاجتك.';

  @override
  String get onboardingPage2Btn => 'بدء';

  @override
  String get onboardingPage3Title => 'تسوق ذكي أخيرًا.';

  @override
  String get onboardingPage3Desc =>
      'لا تشتري مكررات مرة أخرى. امسح، أضف، وقائمتك محدثة.';

  @override
  String get onboardingPage3Btn => 'ابدأ المغامرة';

  @override
  String get onboardingHaveAccount => 'لدي حساب بالفعل';

  @override
  String get paywallTitle => 'انتقل إلى المستوى التالي';

  @override
  String get paywallSubtitle =>
      'افتح الإمكانات الكاملة لمطبخك ووفر ما يصل إلى 500 يورو سنويًا.';

  @override
  String get paywallBenefit1Title => 'مسح الإيصالات بالذكاء الاصطناعي';

  @override
  String get paywallBenefit1Desc => 'أضف مشترياتك في ثانيتين.';

  @override
  String get paywallBenefit2Title => 'وصفات سحرية';

  @override
  String get paywallBenefit2Desc => 'توليد غير محدود بالصور.';

  @override
  String get paywallBenefit3Title => 'تنبيهات ضد الهدر';

  @override
  String get paywallBenefit3Desc => 'احصل على تحذير قبل فوات الأوان.';

  @override
  String get paywallBenefit4Title => 'ماسح الصحة';

  @override
  String get paywallBenefit4Desc => 'Nutri-Score وتفاصيل المنتج.';

  @override
  String get paywallBenefit5Title => 'مشاركة عائلية';

  @override
  String get paywallBenefit5Desc => 'ادعُ عائلتك.';

  @override
  String get paywallAnnual => 'سنوي';

  @override
  String get paywallMonthly => 'شهري';

  @override
  String get paywallSaveLabel => 'وفر 50%';

  @override
  String get paywallSubscribeBtn => 'اشترك الآن';

  @override
  String get paywallRestoreBtn => 'استعادة المشتريات';

  @override
  String get paywallLegalText =>
      'بدون التزام. قابل للإلغاء في أي وقت. بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get paywallSuccess => 'مرحبًا بك في نادي FrigoZen Pro! 🌟';

  @override
  String get paywallError =>
      'تعذر تحميل العروض. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get favoritesTitle => 'كتاب الطبخ الخاص بي';

  @override
  String get favoritesEmptyTitle => 'لا توجد وصفات مفضلة بعد';

  @override
  String get favoritesEmptySubtitle => 'احفظ الوصفات التي تعجبك لتجدها هنا.';

  @override
  String get favoritesLockedTitle => 'ميزة بريميوم';

  @override
  String get favoritesLockedSubtitle =>
      'انتقل إلى FrigoZen Pro لحفظ وصفات الذكاء الاصطناعي الخاصة بك وإنشاء كتاب الطبخ الشخصي الخاص بك.';

  @override
  String get favoritesUnlockBtn => 'فتح كتاب الطبخ';

  @override
  String get favoritesUntitled => 'وصفة بدون عنوان';

  @override
  String get favoritesNoDesc => 'لا يوجد وصف.';

  @override
  String get recipeDetailUntitled => 'وصفة بدون عنوان';

  @override
  String get recipeDetailNoDesc => 'لا يوجد وصف متاح.';

  @override
  String get recipeDetailFridge => 'ثلاجتك';

  @override
  String get recipeDetailToBuy => 'للشراء';

  @override
  String get recipeDetailPreparation => 'التحضير';

  @override
  String get recipeDetailSaved => 'تمت إضافة الوصفة إلى المفضلة! ❤️';

  @override
  String get recipeDetailRemoved => 'تمت إزالة الوصفة من المفضلة.';

  @override
  String recipeDetailError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get recipeSuggestionTitle => 'أفكار وصفات';

  @override
  String get recipeSuggestionEmpty =>
      'لم يتم العثور على وصفات لهذه المجموعة. :(';

  @override
  String get recipeSuggestionUntitled => 'وصفة بدون عنوان';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccountInfo => 'معلومات الحساب';

  @override
  String get settingsNoEmail => 'لا يوجد بريد إلكتروني متاح';

  @override
  String get settingsManageSub => 'إدارة الاشتراك';

  @override
  String get settingsUpgrade => 'الترقية إلى FrigoZen Pro';

  @override
  String get settingsProMember => 'أنت عضو Pro.';

  @override
  String get settingsUnlockFeatures => 'افتح جميع الميزات.';

  @override
  String get settingsErrorOpen => 'تعذر فتح الإعدادات';

  @override
  String get settingsRestore => 'استعادة المشتريات';

  @override
  String get settingsRestoreSuccess => 'تمت استعادة المشتريات بنجاح.';

  @override
  String settingsRestoreFail(String error) {
    return 'فشل الاستعادة: $error';
  }

  @override
  String get settingsFamilyHeader => 'العائلة والمنزل';

  @override
  String get settingsDefaultHouse => 'المنزل';

  @override
  String get settingsInviteMembers => 'دعوة أعضاء';

  @override
  String get settingsInvitePremiumHint => 'كن Premium لمشاركة مخزونك.';

  @override
  String get settingsInviteCodeLabel => 'رمز الدعوة:';

  @override
  String get settingsCodeCopied => 'تم نسخ الرمز!';

  @override
  String get settingsShareHint => 'شارك هذا الرمز لدعوة عائلتك.';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get shoppingTitle => 'قائمة التسوق';

  @override
  String get shoppingItemNoTitle => 'منتج غير معروف';

  @override
  String shoppingDuplicateAlert(String itemName) {
    return '💡 انتبه! لديك بالفعل \"$itemName\" في مخزونك!';
  }

  @override
  String get shoppingAddAnyway => 'إضافة على أي حال';

  @override
  String shoppingErrorGeneric(String error) {
    return 'خطأ: $error';
  }

  @override
  String shoppingMovedSuccess(int count) {
    return 'تم نقل $count منتج(ات) إلى المخزون بنجاح!';
  }

  @override
  String shoppingMoveError(String error) {
    return 'خطأ أثناء النقل: $error';
  }

  @override
  String get shoppingAddingBtn => 'جاري الإضافة...';

  @override
  String shoppingMoveBtn(int count) {
    return 'نقل $count منتج(ات) إلى المخزون';
  }

  @override
  String validationTitle(int count) {
    return 'التحقق من المنتجات ($count)';
  }

  @override
  String get validationCancelBtn => 'إلغاء';

  @override
  String validationAddBtn(int count) {
    return 'إضافة $count منتجات';
  }

  @override
  String validationSuccess(int count) {
    return 'تمت إضافة $count منتجات إلى المخزون!';
  }

  @override
  String validationError(String error) {
    return 'خطأ أثناء الإضافة: $error';
  }

  @override
  String get shoppingListEmptyTitle => 'قائمة التسوق الخاصة بك فارغة';

  @override
  String get shoppingListEmptySubtitle => 'أضف منتجًا أعلاه للبدء.';

  @override
  String get inputFieldHintText => 'أضف إلى قائمة التسوق';

  @override
  String editBatchesTitle(String itemName) {
    return 'إدارة التواريخ: $itemName';
  }

  @override
  String get editBatchesSubtitle => 'انقر على القلم لتغيير التاريخ.';

  @override
  String get editBatchesEmpty => 'لا توجد معلومات عن التاريخ.';

  @override
  String get editBatchesExpiredPrefix => 'انتهت صلاحيته في';

  @override
  String get editBatchesExpiresPrefix => 'تنتهي صلاحيته في';

  @override
  String get editBatchesSuccess => 'تم تحديث التاريخ بنجاح! ✅';

  @override
  String editBatchesError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get mealPlannerTitle => 'مخطط الوجبات';

  @override
  String get mealPlannerGenerateList => 'إنشاء قائمة التسوق';

  @override
  String get mealPlannerBreakfast => 'فطور ☕';

  @override
  String get mealPlannerLunch => 'الغداء ☀️';

  @override
  String get mealPlannerSnack => 'وجبة خفيفة 🍎';

  @override
  String get mealPlannerDinner => 'العشاء 🌙';

  @override
  String get mealPlannerAddMeal => 'إضافة وجبة';

  @override
  String get mealPlannerEditMeal => 'تعديل الوجبة';

  @override
  String get mealPlannerMealNameLabel => 'اسم الوجبة';

  @override
  String get mealPlannerMealNameHint => 'مثال: معكرونة كاربونارا';

  @override
  String get mealPlannerIngredientsLabel => 'المكونات (مفصولة بفواصل)';

  @override
  String get mealPlannerIngredientsHint =>
      'مثال: معكرونة، لحم مقدد، كريمة، بيض';

  @override
  String get mealPlannerCancel => 'إلغاء';

  @override
  String get mealPlannerModify => 'تعديل';

  @override
  String get mealPlannerAdd => 'إضافة';

  @override
  String get mealPlannerAnalyzing => 'جاري تحليل المخزون وإنشاء القائمة... ⏳';

  @override
  String mealPlannerAddedIngredients(int count) {
    return 'تمت إضافة $count مكونات إلى القائمة!';
  }

  @override
  String get mealPlannerViewList => 'عرض';

  @override
  String get paywallBenefitSmartListTitle => 'قائمة ذكية';

  @override
  String get paywallBenefitSmartListDesc => 'إنشاء تلقائي وذكي.';

  @override
  String get mealPlannerSmartListUpsell =>
      'انتقل إلى Pro لإنشاء قائمة ذكية بالذكاء الاصطناعي!';

  @override
  String get mealPlannerGoPremium => 'كن Premium';

  @override
  String get paywallTermsButton => 'الشروط والأحكام';

  @override
  String get dashboardTitle => 'لوحة القيادة';

  @override
  String get quickActionsTitle => 'إجراءات سريعة';

  @override
  String get scanActionLabel => 'مسح';

  @override
  String get addActionLabel => 'إضافة';

  @override
  String get mealPlannerCardTitle => 'مخطط وجباتي';

  @override
  String get mealPlannerCardSubtitle => 'خطط لوجباتك الأسبوعية';

  @override
  String get expiringSoonTitle => 'تأكل قريبا!';

  @override
  String get cookWithFridgeBtn => 'اطبخ مع ثلاجتي';

  @override
  String get summaryTotal => 'المجموع';

  @override
  String get summaryToEat => 'للأكل';

  @override
  String get summaryShopping => 'التسوق';

  @override
  String get expiredLabel => 'منتهية الصلاحية';

  @override
  String get todayLabel => 'اليوم';

  @override
  String daysLeftLabel(int days) {
    return 'ي-$days';
  }

  @override
  String get statsTopCategories => 'أهم الفئات';

  @override
  String get statsNutriScore => 'الجودة الغذائية';

  @override
  String statsScoreLabel(String score) {
    return 'النتيجة $score';
  }

  @override
  String get statsPremiumLabel => 'إحصائيات مميزة';

  @override
  String get statsUnlockBtn => 'فتح';

  @override
  String get statsStorageDistribution => 'توزيع التخزين';

  @override
  String get statsFavoriteStores => 'متاجرك المفضلة';

  @override
  String get recipeFinding => 'جاري البحث عن وصفات...';

  @override
  String get inventoryEmpty => 'مخزونك فارغ!';

  @override
  String get recipesNotFound => 'لم يتم العثور على وصفات.';

  @override
  String errorGeneric(String error) {
    return 'خطأ: $error';
  }

  @override
  String get renameProductTitle => 'إعادة تسمية المنتج';

  @override
  String get newNameLabel => 'اسم جديد';

  @override
  String get cancelBtn => 'إلغاء';

  @override
  String get saveBtn => 'حفظ';

  @override
  String get renameTooltip => 'إعادة تسمية';

  @override
  String addedOnDate(String date) {
    return 'أضيف في $date';
  }

  @override
  String get editBatchTitle => 'تعديل الدفعة';

  @override
  String get specificNameLabel => 'اسم محدد';

  @override
  String get specificNameHint => 'مثال: بيض عضوي';

  @override
  String get brandLabel => 'العلامة التجارية';

  @override
  String get brandHint => 'مثال: Bio Village';

  @override
  String get storeLabel => 'المتجر';

  @override
  String get storeHint => 'مثال: كارفور';

  @override
  String get nutriScoreLabel => 'Nutri-Score';

  @override
  String get nutriScoreUndefined => 'غير محدد';

  @override
  String get expirationDateLabel => 'تاريخ انتهاء الصلاحية';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get searchNoResults => 'لم يتم العثور على نتائج';

  @override
  String get searchTryDifferent => 'جرب مصطلح بحث مختلف.';

  @override
  String get statusExpired => 'منتهية الصلاحية';

  @override
  String get statusExpiresToday => 'تنتهي الصلاحية اليوم';

  @override
  String get statusExpiresSoon => 'تنتهي الصلاحية قريبا';

  @override
  String statusExpiresInDays(int days) {
    return 'تنتهي الصلاحية في $days أيام';
  }

  @override
  String get statusFresh => 'طازج';

  @override
  String get scanBarcodeTitle => 'مسح الرمز الشريطي';

  @override
  String get productUnknown => 'منتج غير معروف';

  @override
  String productAdded(String name) {
    return 'تمت إضافة $name!';
  }

  @override
  String get productNotFoundOFF => 'المنتج غير موجود في Open Food Facts.';

  @override
  String serverErrorOFF(Object code) {
    return 'خطأ في خادم OFF ($code)';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get shoppingItemAlreadyInStockTitle => 'المنتج موجود بالفعل';

  @override
  String shoppingItemAlreadyInStockMessage(String itemName) {
    return 'لديك بالفعل \'$itemName\' في مخزونك. هل تريد إضافته إلى قائمة التسوق على أي حال؟';
  }

  @override
  String get shoppingDialogNo => 'لا';

  @override
  String get shoppingDialogYesAdd => 'نعم، أضف';

  @override
  String get shoppingFinishedTitle => 'انتهى التسوق! 🎉';

  @override
  String get shoppingDialogStay => 'البقاء هنا';

  @override
  String get shoppingDialogViewInventory => 'عرض المخزون';

  @override
  String get shoppingUncheckAllTooltip => 'إلغاء تحديد الكل';

  @override
  String get shoppingCheckAllTooltip => 'تحديد الكل';

  @override
  String get shoppingDeleteAllTooltip => 'حذف الكل';

  @override
  String get shoppingDeleteAllTitle => 'حذف الكل؟';

  @override
  String get shoppingDeleteAllMessage =>
      'هل تريد حقًا مسح قائمة التسوق الخاصة بك؟ هذا الإجراء لا رجعة فيه.';

  @override
  String get shoppingDialogCancel => 'إلغاء';

  @override
  String get shoppingDialogDelete => 'حذف';

  @override
  String get shoppingCategoryOther => 'أخرى';

  @override
  String get recipeTitle => 'الوصفات';

  @override
  String get recipeTabDiscover => 'اكتشف';

  @override
  String get recipeTabCatalog => 'كتالوج';

  @override
  String get recipeTabAI => 'طاهي الذكاء الاصطناعي';

  @override
  String get recipeAITitle => 'اطبخ بمحتويات ثلاجتك';

  @override
  String get recipeAIDesc =>
      'دع طاهي الذكاء الاصطناعي يولد وصفات لذيذة بناءً على مخزونك.';

  @override
  String get recipeAIBtn => 'توليد وصفات';

  @override
  String get recipeTabFavorites => 'المفضلة';

  @override
  String get recipeSearchHint => 'البحث عن وصفة...';

  @override
  String get recipeNoResults => 'لم يتم العثور على وصفات.';

  @override
  String get recipeIngredientsAddedTitle => 'تمت إضافة المكونات!';

  @override
  String get recipeIngredientsAddedMessage =>
      'تمت إضافة المكونات إلى قائمة التسوق الخاصة بك. هل تريد رؤيتها الآن؟';

  @override
  String get recipeDialogStay => 'البقاء هنا';

  @override
  String get recipeDialogViewList => 'عرض القائمة';

  @override
  String recipeAddError(String error) {
    return 'خطأ أثناء إضافة العناصر: $error';
  }

  @override
  String get recipeMealTypeTitle => 'أي وجبة؟';

  @override
  String get recipeMealTypeBreakfast => 'فطور ☕';

  @override
  String get recipeMealTypeLunch => 'غداء ☀️';

  @override
  String get recipeMealTypeSnack => 'وجبة خفيفة 🍎';

  @override
  String get recipeMealTypeDinner => 'عشاء 🌙';

  @override
  String get recipeAddedToPlanning => 'تمت إضافة الوصفة إلى المخطط!';

  @override
  String get recipeViewPlanning => 'عرض';

  @override
  String recipeError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get recipeIngredientsTitle => 'المكونات';

  @override
  String get recipeAddIngredientsBtn => 'أضف إلى قائمة التسوق';

  @override
  String get recipeFilterTitle => 'تفضيلات الطاهي';

  @override
  String get recipeFilterMealType => 'نوع الوجبة';

  @override
  String get recipeFilterDiet => 'النظام الغذائي';

  @override
  String get recipeFilterDifficulty => 'الصعوبة';

  @override
  String get recipeFilterGenerate => 'توليد';

  @override
  String get recipeFilterCancel => 'إلغاء';

  @override
  String get settingsSubscriptionHeader => 'الاشتراك';

  @override
  String get settingsAboutHeader => 'حول';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsTermsOfService => 'شروط الخدمة';

  @override
  String get settingsEditProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get settingsDisplayNameLabel => 'الاسم المعروض';

  @override
  String get settingsCancelBtn => 'إلغاء';

  @override
  String get settingsSaveBtn => 'حفظ';

  @override
  String get settingsProfileUpdated => 'تم تحديث الملف الشخصي!';

  @override
  String settingsErrorGeneric(String error) {
    return 'خطأ: $error';
  }

  @override
  String get householdNameRequired => 'اسم المنزل مطلوب';

  @override
  String get householdCodeRequired => 'رمز الدعوة مطلوب';

  @override
  String recipeMissingIngredientsCount(int count) {
    return 'مفقود: $count';
  }

  @override
  String get mealPlannerIngredientsAddedMessage =>
      'تمت إضافة المكونات إلى قائمة التسوق الخاصة بك.';

  @override
  String get mealPlannerNoIngredientsAddedTitle => 'لم يتم إضافة أي مكونات';

  @override
  String get mealPlannerNoIngredientsAddedMessage =>
      'جميع المكونات الضرورية موجودة بالفعل في قائمتك أو مخزونك.';

  @override
  String get ok => 'حسنا';

  @override
  String get cat_fruits_vegetables => 'فواكه وخضروات';

  @override
  String get cat_bakery => 'مخبز';

  @override
  String get cat_dairy_eggs => 'منتجات الألبان والبيض';

  @override
  String get cat_meat_fish => 'لحوم وأسماك';

  @override
  String get cat_frozen => 'مجمدات';

  @override
  String get cat_pantry_salty => 'مؤن مالحة';

  @override
  String get cat_pantry_sweet => 'مؤن حلوة';

  @override
  String get cat_beverages => 'مشروبات';

  @override
  String get cat_baby => 'أطفال';

  @override
  String get cat_pets => 'حيوانات أليفة';

  @override
  String get cat_other => 'أخرى';

  @override
  String get loc_fridge => 'ثلاجة';

  @override
  String get loc_freezer => 'مجمد';

  @override
  String get loc_pantry => 'مخزن';

  @override
  String get scanProTip =>
      'نصيحة: امسح الباركود للحصول على مزيد من التفاصيل (Nutri-Score، إلخ)!';

  @override
  String get shoppingPrioritizeScanTitle => 'هل لديك الإيصال؟';

  @override
  String get shoppingPrioritizeScanMessage =>
      'بصفتك عضوًا مميزًا، يمكنك مسح الإيصال لإضافة عناصر بمزيد من التفاصيل (العلامة التجارية، Nutri-Score، إلخ).\n\nإذا قمت بمسح الإيصال، فلا تضف هذه العناصر يدويًا لتجنب التكرار.';

  @override
  String get shoppingPrioritizeScanBtn => 'مسح الإيصال';

  @override
  String get shoppingPrioritizeManualBtn => 'لا، إضافة يدوية';

  @override
  String get scanAnalyzing => 'جارٍ تحليل الإيصال...';
}
