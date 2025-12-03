// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FrigoZen';

  @override
  String get inventoryTab => 'Inventario';

  @override
  String get shoppingListTab => 'Lista de compras';

  @override
  String get favoritesTab => 'Favoritos';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get scanReceipt => 'Escanear recibo';

  @override
  String get db_milk => 'Leche';

  @override
  String get db_chicken => 'Pollo';

  @override
  String get db_apple => 'Manzana';

  @override
  String get db_tomato => 'Tomate';

  @override
  String get db_pasta => 'Pasta';

  @override
  String get db_rice => 'Arroz';

  @override
  String get authWelcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get authWelcome => 'Bienvenido a FrigoZen';

  @override
  String get authLoginSubtitle => 'Inicia sesión para gestionar tu nevera.';

  @override
  String get authSignupSubtitle => 'Crea una cuenta para empezar a ahorrar.';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authLoginBtn => 'Iniciar sesión';

  @override
  String get authSignupBtn => 'Registrarse';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authCreateAccount => 'Crear una cuenta';

  @override
  String get authHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get authToLogin => 'Iniciar sesión';

  @override
  String get authSuccess =>
      'Cuenta creada con éxito. Ya puedes iniciar sesión.';

  @override
  String get authErrorGeneric =>
      'Ocurrió un error, por favor verifica tus credenciales.';

  @override
  String get authErrorNoUser => 'No se encontró usuario para este correo.';

  @override
  String get authErrorWrongPass => 'Contraseña incorrecta.';

  @override
  String get authErrorEmailInUse => 'Este correo ya está en uso.';

  @override
  String get authErrorWeakPass => 'La contraseña es demasiado débil.';

  @override
  String get authFieldRequired => 'Este campo es obligatorio.';

  @override
  String get authInvalidEmail => 'Por favor ingresa un correo válido.';

  @override
  String get authShortPassword =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get householdWelcome => '¡Bienvenido a casa!';

  @override
  String get householdSubtitle =>
      'Para comenzar, crea tu espacio familiar o únete a uno existente.';

  @override
  String get householdCreateTitle => 'Crear un nuevo espacio';

  @override
  String get householdNameLabel => 'Nombre del hogar (ej: Mi Casa)';

  @override
  String get householdCreateBtn => 'Crear';

  @override
  String get householdOr => 'O';

  @override
  String get householdJoinTitle => 'Unirse a un espacio';

  @override
  String get householdCodeLabel => 'Código de invitación (ej: FZ-1234)';

  @override
  String get householdJoinBtn => 'Unirse';

  @override
  String get householdErrorNameRequired => 'El nombre es obligatorio';

  @override
  String get householdErrorCodeRequired => 'El código es obligatorio';

  @override
  String get addItemTitle => 'Añadir nuevo producto';

  @override
  String get addItemNameLabel => 'Nombre (ej: Leche)';

  @override
  String get addItemNameError => 'Por favor ingresa un nombre.';

  @override
  String addItemQuantityLabel(int quantity) {
    return 'Cantidad : $quantity';
  }

  @override
  String get addItemSaveBtn => 'Guardar';

  @override
  String addItemError(String error) {
    return 'Error: $error';
  }

  @override
  String get inventoryTitle => 'Mi Inventario';

  @override
  String get inventoryTabAll => 'Todo';

  @override
  String get inventoryTabFridge => 'Nevera';

  @override
  String get inventoryTabPantry => 'Despensa';

  @override
  String get inventoryTabFreezer => 'Congelador';

  @override
  String get inventorySearchHint => 'Buscar un producto...';

  @override
  String get inventoryEmptyTitle => 'Tu inventario está vacío';

  @override
  String get inventoryEmptySubtitle => 'Toca + para añadir un producto.';

  @override
  String get suggestRecipeTooltip => 'Sugerir receta';

  @override
  String get scanReceiptCamera => 'Escanear recibo (Cámara)';

  @override
  String get scanReceiptGallery => 'Seleccionar de galería';

  @override
  String get scanManual => 'Añadir manualmente';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingPage1Title => 'Deja de tirar tu dinero.';

  @override
  String get onboardingPage1Desc =>
      'FrigoZen te ayuda a consumir tus alimentos antes de que caduquen.';

  @override
  String get onboardingPage1Btn => 'Continuar';

  @override
  String get onboardingPage2Title => 'Sabe siempre qué comer.';

  @override
  String get onboardingPage2Desc =>
      'Recibe recetas sencillas basadas en lo que ya tienes en tu nevera.';

  @override
  String get onboardingPage2Btn => 'Empezar';

  @override
  String get onboardingPage3Title => 'Compras inteligentes por fin.';

  @override
  String get onboardingPage3Desc =>
      'Nunca vuelvas a comprar duplicados. Escanea, añade, y tu lista está al día.';

  @override
  String get onboardingPage3Btn => 'Comenzar la aventura';

  @override
  String get onboardingHaveAccount => 'Ya tengo una cuenta';

  @override
  String get paywallTitle => 'Llévalo al siguiente nivel';

  @override
  String get paywallSubtitle =>
      'Desbloquea todo el potencial de tu cocina y ahorra hasta 500€ al año.';

  @override
  String get paywallBenefit1Title => 'Escaneo de Recibos IA';

  @override
  String get paywallBenefit1Desc => 'Añade tus compras en 2 segundos.';

  @override
  String get paywallBenefit2Title => 'Recetas Mágicas';

  @override
  String get paywallBenefit2Desc => 'Generación ilimitada con fotos.';

  @override
  String get paywallBenefit3Title => 'Alertas Anti-Desperdicio';

  @override
  String get paywallBenefit3Desc =>
      'Recibe avisos antes de que sea demasiado tarde.';

  @override
  String get paywallBenefit4Title => 'Escáner de Salud';

  @override
  String get paywallBenefit4Desc => 'Nutri-Score y detalles de productos.';

  @override
  String get paywallBenefit5Title => 'Compartir en Familia';

  @override
  String get paywallBenefit5Desc => 'Invita a tu hogar.';

  @override
  String get paywallAnnual => 'Anual';

  @override
  String get paywallMonthly => 'Mensual';

  @override
  String get paywallSaveLabel => 'AHORRA 50%';

  @override
  String get paywallSubscribeBtn => 'Suscribirse ahora';

  @override
  String get paywallRestoreBtn => 'Restaurar compras';

  @override
  String get paywallLegalText =>
      'Sin compromiso. Cancelable en cualquier momento. Al continuar, aceptas los Términos de Servicio y la Política de Privacidad.';

  @override
  String get paywallSuccess => '¡Bienvenido al club FrigoZen Pro! 🌟';

  @override
  String get favoritesTitle => 'Mi Libro de Cocina';

  @override
  String get favoritesEmptyTitle => 'Aún no hay recetas favoritas';

  @override
  String get favoritesEmptySubtitle =>
      'Guarda las recetas que te gusten para encontrarlas aquí.';

  @override
  String get favoritesLockedTitle => 'Función Premium';

  @override
  String get favoritesLockedSubtitle =>
      'Pásate a FrigoZen Pro para guardar tus recetas de IA y crear tu libro de cocina personal.';

  @override
  String get favoritesUnlockBtn => 'Desbloquear Libro de Cocina';

  @override
  String get favoritesUntitled => 'Receta sin título';

  @override
  String get favoritesNoDesc => 'Sin descripción.';

  @override
  String get recipeDetailUntitled => 'Receta sin título';

  @override
  String get recipeDetailNoDesc => 'No hay descripción disponible.';

  @override
  String get recipeDetailFridge => 'TU NEVERA';

  @override
  String get recipeDetailToBuy => 'A COMPRAR';

  @override
  String get recipeDetailPreparation => 'PREPARACIÓN';

  @override
  String get recipeDetailSaved => '¡Receta añadida a Favoritos! ❤️';

  @override
  String get recipeDetailRemoved => 'Receta eliminada de Favoritos.';

  @override
  String recipeDetailError(String error) {
    return 'Error: $error';
  }

  @override
  String get recipeSuggestionTitle => 'Ideas de Recetas';

  @override
  String get recipeSuggestionEmpty =>
      'No se encontraron recetas para esta combinación. :(';

  @override
  String get recipeSuggestionUntitled => 'Receta sin título';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccountInfo => 'Información de la cuenta';

  @override
  String get settingsNoEmail => 'No hay correo disponible';

  @override
  String get settingsManageSub => 'Gestionar suscripción';

  @override
  String get settingsUpgrade => 'Pasar a FrigoZen Pro';

  @override
  String get settingsProMember => 'Eres miembro Pro.';

  @override
  String get settingsUnlockFeatures => 'Desbloquea todas las funciones.';

  @override
  String get settingsErrorOpen => 'No se pudieron abrir los ajustes';

  @override
  String get settingsRestore => 'Restaurar compras';

  @override
  String get settingsRestoreSuccess => 'Compras restauradas con éxito.';

  @override
  String settingsRestoreFail(String error) {
    return 'Fallo al restaurar: $error';
  }

  @override
  String get settingsFamilyHeader => 'FAMILIA Y HOGAR';

  @override
  String get settingsDefaultHouse => 'Casa';

  @override
  String get settingsInviteMembers => 'Invitar miembros';

  @override
  String get settingsInvitePremiumHint =>
      'Hazte Premium para compartir tu inventario.';

  @override
  String get settingsInviteCodeLabel => 'Código de invitación:';

  @override
  String get settingsCodeCopied => '¡Código copiado!';

  @override
  String get settingsShareHint =>
      'Comparte este código para invitar a tu familia.';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get shoppingTitle => 'Lista de compras';

  @override
  String get shoppingItemNoTitle => 'Artículo desconocido';

  @override
  String shoppingDuplicateAlert(String itemName) {
    return '💡 ¡Atención! ¡Ya tienes \"$itemName\" en tu inventario!';
  }

  @override
  String get shoppingAddAnyway => 'Añadir de todos modos';

  @override
  String shoppingErrorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String shoppingMovedSuccess(int count) {
    return '¡$count artículo(s) movido(s) al inventario con éxito!';
  }

  @override
  String shoppingMoveError(String error) {
    return 'Error al mover: $error';
  }

  @override
  String get shoppingAddingBtn => 'Añadiendo...';

  @override
  String shoppingMoveBtn(int count) {
    return 'Mover $count artículo(s) al inventario';
  }

  @override
  String validationTitle(int count) {
    return 'Validar artículos ($count)';
  }

  @override
  String get validationCancelBtn => 'Cancelar';

  @override
  String validationAddBtn(int count) {
    return 'Añadir $count artículos';
  }

  @override
  String validationSuccess(int count) {
    return '¡$count artículos añadidos al inventario!';
  }

  @override
  String validationError(String error) {
    return 'Error al añadir: $error';
  }

  @override
  String get shoppingListEmptyTitle => 'Tu lista de compras está vacía';

  @override
  String get shoppingListEmptySubtitle =>
      'Añade un artículo arriba para empezar.';

  @override
  String get inputFieldHintText => 'Añadir a la lista de compras';

  @override
  String editBatchesTitle(String itemName) {
    return 'Gestionar fechas: $itemName';
  }

  @override
  String get editBatchesSubtitle =>
      'Haz clic en el lápiz para cambiar una fecha.';

  @override
  String get editBatchesEmpty => 'Sin información de fecha.';

  @override
  String get editBatchesExpiredPrefix => 'CADUCADO EL';

  @override
  String get editBatchesExpiresPrefix => 'Caduca el';

  @override
  String get editBatchesSuccess => '¡Fecha actualizada con éxito! ✅';

  @override
  String editBatchesError(String error) {
    return 'Error: $error';
  }

  @override
  String get mealPlannerTitle => 'Mi Planificador de Comidas';

  @override
  String get mealPlannerGenerateList => 'Generar lista de compras';

  @override
  String get mealPlannerLunch => 'Almuerzo ☀️';

  @override
  String get mealPlannerDinner => 'Cena 🌙';

  @override
  String get mealPlannerAddMeal => 'Añadir una comida';

  @override
  String get mealPlannerEditMeal => 'Editar comida';

  @override
  String get mealPlannerMealNameLabel => 'Nombre de la comida';

  @override
  String get mealPlannerMealNameHint => 'Ej: Pasta Carbonara';

  @override
  String get mealPlannerIngredientsLabel =>
      'Ingredientes (separados por comas)';

  @override
  String get mealPlannerIngredientsHint => 'Ej: Pasta, Tocino, Crema, Huevos';

  @override
  String get mealPlannerCancel => 'Cancelar';

  @override
  String get mealPlannerModify => 'Modificar';

  @override
  String get mealPlannerAdd => 'Añadir';

  @override
  String get mealPlannerAnalyzing =>
      'Analizando inventario y generando lista... ⏳';

  @override
  String mealPlannerAddedIngredients(int count) {
    return '¡$count ingredientes añadidos a la lista!';
  }

  @override
  String get mealPlannerViewList => 'VER';

  @override
  String get paywallBenefitSmartListTitle => 'Lista Inteligente';

  @override
  String get paywallBenefitSmartListDesc =>
      'Generación automática e inteligente.';

  @override
  String get mealPlannerSmartListUpsell =>
      '¡Pásate a Pro para la generación inteligente con IA!';

  @override
  String get mealPlannerGoPremium => 'Hazte Premium';

  @override
  String get paywallTermsButton => 'Términos y Condiciones';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get quickActionsTitle => 'Acciones rápidas';

  @override
  String get scanActionLabel => 'Escanear';

  @override
  String get addActionLabel => 'Añadir';

  @override
  String get mealPlannerCardTitle => 'Mi planificador';

  @override
  String get mealPlannerCardSubtitle => 'Planifica tus comidas de la semana';

  @override
  String get expiringSoonTitle => '¡Comer pronto!';

  @override
  String get cookWithFridgeBtn => 'Cocinar con mi nevera';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryToEat => 'Para comer';

  @override
  String get summaryShopping => 'Compras';

  @override
  String get expiredLabel => 'Caducado';

  @override
  String get todayLabel => 'Hoy';

  @override
  String daysLeftLabel(int days) {
    return 'D-$days';
  }

  @override
  String get statsTopCategories => 'Categorías Principales';

  @override
  String get statsNutriScore => 'Calidad Nutricional';

  @override
  String statsScoreLabel(String score) {
    return 'Puntuación $score';
  }

  @override
  String get statsPremiumLabel => 'Estadísticas Premium';

  @override
  String get statsUnlockBtn => 'Desbloquear';

  @override
  String get statsStorageDistribution => 'Distribución por Almacenamiento';

  @override
  String get statsFavoriteStores => 'Tus Tiendas Favoritas';

  @override
  String get recipeFinding => 'Buscando recetas...';

  @override
  String get inventoryEmpty => '¡Tu inventario está vacío!';

  @override
  String get recipesNotFound => 'No se encontraron recetas.';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get renameProductTitle => 'Renombrar producto';

  @override
  String get newNameLabel => 'Nuevo nombre';

  @override
  String get cancelBtn => 'Cancelar';

  @override
  String get saveBtn => 'Guardar';

  @override
  String get renameTooltip => 'Renombrar';

  @override
  String addedOnDate(String date) {
    return 'Añadido el $date';
  }

  @override
  String get editBatchTitle => 'Editar lote';

  @override
  String get specificNameLabel => 'Nombre específico';

  @override
  String get specificNameHint => 'ej. Huevos Ecológicos';

  @override
  String get brandLabel => 'Marca';

  @override
  String get brandHint => 'ej. Bio Village';

  @override
  String get storeLabel => 'Tienda';

  @override
  String get storeHint => 'ej. Mercadona';

  @override
  String get nutriScoreLabel => 'Nutri-Score';

  @override
  String get nutriScoreUndefined => 'Indefinido';

  @override
  String get expirationDateLabel => 'Fecha de caducidad';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get searchNoResults => 'No se encontraron resultados';

  @override
  String get searchTryDifferent => 'Prueba con otro término de búsqueda.';

  @override
  String get statusExpired => 'Caducado';

  @override
  String get statusExpiresToday => 'Caduca hoy';

  @override
  String get statusExpiresSoon => 'Caduca pronto';

  @override
  String statusExpiresInDays(int days) {
    return 'Caduca en $days días';
  }

  @override
  String get statusFresh => 'Fresco';

  @override
  String get scanBarcodeTitle => 'Escanear código de barras';

  @override
  String get productUnknown => 'Producto desconocido';

  @override
  String productAdded(String name) {
    return '¡$name añadido!';
  }

  @override
  String get productNotFoundOFF => 'Producto no encontrado en Open Food Facts.';

  @override
  String serverErrorOFF(Object code) {
    return 'Error del servidor OFF ($code)';
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
  String get recipeMealTypeLunch => 'Lunch ☀️';

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
  String get recipeFilterGenerate => 'Generar';

  @override
  String get recipeFilterCancel => 'Cancelar';

  @override
  String get settingsSubscriptionHeader => 'Suscripción';

  @override
  String get settingsAboutHeader => 'Acerca de';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTermsOfService => 'Términos de servicio';

  @override
  String get settingsEditProfileTitle => 'Editar perfil';

  @override
  String get settingsDisplayNameLabel => 'Nombre para mostrar';

  @override
  String get settingsCancelBtn => 'Cancelar';

  @override
  String get settingsSaveBtn => 'Guardar';

  @override
  String get settingsProfileUpdated => '¡Perfil actualizado!';

  @override
  String settingsErrorGeneric(String error) {
    return 'Error: $error';
  }
}
