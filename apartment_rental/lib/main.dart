import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/apartment_provider.dart';
import 'providers/rental_provider.dart';
import 'providers/expense_provider.dart';
import 'localization/app_localizations.dart';
import 'repositories/repositories.dart';
import 'services/api_service.dart';
import 'services/local_database.dart';
import 'services/connectivity_service.dart';
import 'services/sync_queue.dart';
import 'services/sync_service.dart';
import 'screens/app_shell.dart';
import 'screens/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final localDb = LocalDatabase();
  final connectivity = ConnectivityService();
  final syncQueue = SyncQueue();

  await localDb.init();
  await connectivity.init();
  await syncQueue.init();

  final syncService = SyncService(
    api: apiService,
    connectivity: connectivity,
    localDb: localDb,
    queue: syncQueue,
  );

  final apartmentRepo = ApartmentRepository(apiService, localDb, connectivity, syncService);
  final rentalRepo = RentalRepository(apiService, localDb, connectivity, syncService);
  final expenseRepo = ExpenseRepository(apiService, localDb, connectivity, syncService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(localDb: localDb, syncQueue: syncQueue),
        ),
        ChangeNotifierProvider(create: (_) => syncService),
        ChangeNotifierProvider(create: (_) => ApartmentProvider(apartmentRepo)),
        ChangeNotifierProvider(create: (_) => RentalProvider(rentalRepo)),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(expenseRepo)),
      ],
      child: const ApartmentRentalApp(),
    ),
  );

  syncService.init();
}

class AppColors {
  static const Color primary = Color(0xFF0A2647);
  static const Color primaryLight = Color(0xFF144272);
  static const Color secondary = Color(0xFF205295);
  static const Color accent = Color(0xFF2C74B3);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color background = Color(0xFFF0F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A2647);
  static const Color textSecondary = Color(0xFF5A7184);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color glass = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
}

class ApartmentRentalApp extends StatelessWidget {
  const ApartmentRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إيجار الشقق',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          if (auth.isLoggedIn) {
            return const AppShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    final cairoTextTheme = GoogleFonts.cairoTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: cairoTextTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.accent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return GoogleFonts.cairo(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 24);
          }
          return IconThemeData(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 24,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
