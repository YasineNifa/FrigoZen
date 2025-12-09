import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigo_zen/screens/planning/meal_planner_screen.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/services/auth_service.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/locator.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<MealPlannerViewModel>(),
  MockSpec<InventoryViewModel>(),
  MockSpec<ShoppingViewModel>(),
  MockSpec<RevenueProvider>(),
  MockSpec<AuthService>(),
  MockSpec<HouseholdRepository>(),
])
import 'meal_planner_crash_test.mocks.dart';

void main() {
  late MockMealPlannerViewModel mockMealPlannerViewModel;
  late MockInventoryViewModel mockInventoryViewModel;
  late MockShoppingViewModel mockShoppingViewModel;
  late MockRevenueProvider mockRevenueProvider;
  late MockAuthService mockAuthService;
  late MockHouseholdRepository mockHouseholdRepository;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('fr_FR', null);
    
    mockMealPlannerViewModel = MockMealPlannerViewModel();
    mockInventoryViewModel = MockInventoryViewModel();
    mockShoppingViewModel = MockShoppingViewModel();
    mockRevenueProvider = MockRevenueProvider();
    mockAuthService = MockAuthService();
    mockHouseholdRepository = MockHouseholdRepository();

    // Register mocks in locator
    locator.reset();
    locator.registerLazySingleton<AuthService>(() => mockAuthService);
    locator.registerLazySingleton<InventoryViewModel>(() => mockInventoryViewModel);
    locator.registerLazySingleton<ShoppingViewModel>(() => mockShoppingViewModel);
    locator.registerLazySingleton<RevenueProvider>(() => mockRevenueProvider);
    locator.registerLazySingleton<MealPlannerViewModel>(() => mockMealPlannerViewModel);
    locator.registerLazySingleton<HouseholdRepository>(() => mockHouseholdRepository);

    // Default stubs
    when(mockMealPlannerViewModel.meals).thenReturn([]);
    when(mockMealPlannerViewModel.isLoading).thenReturn(false);
    when(mockRevenueProvider.isPro).thenReturn(true);
    when(mockAuthService.currentUserId).thenReturn('test_user_id');
    when(mockHouseholdRepository.getHouseholdIdForUser('test_user_id'))
        .thenAnswer((_) async => 'test_household_id');
  });

  testWidgets('MealPlannerScreen renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MealPlannerViewModel>.value(value: mockMealPlannerViewModel),
          ChangeNotifierProvider<InventoryViewModel>.value(value: mockInventoryViewModel),
          ChangeNotifierProvider<ShoppingViewModel>.value(value: mockShoppingViewModel),
          ChangeNotifierProvider<RevenueProvider>.value(value: mockRevenueProvider),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          locale: const Locale('fr'),
          home: const MealPlannerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(MealPlannerScreen), findsOneWidget);
    expect(find.text('Une erreur est survenue'), findsNothing);
  });
}
