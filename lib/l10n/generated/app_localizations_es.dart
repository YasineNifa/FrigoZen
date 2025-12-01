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
}
