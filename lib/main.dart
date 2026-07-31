import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hamster_points/screens/home_screen.dart';
import 'package:hamster_points/screens/tasks_screen.dart';
import 'package:hamster_points/screens/market_screen.dart';
import 'package:hamster_points/screens/my_farm_screen.dart';
import 'package:hamster_points/screens/wallet_screen.dart';
import 'package:hamster_points/screens/referral_screen.dart';
import 'package:hamster_points/screens/splash_screen.dart';
import 'package:hamster_points/screens/onboarding_screen.dart';
import 'package:hamster_points/screens/auth_screen.dart';
import 'package:hamster_points/screens/profile_screen.dart';
import 'package:hamster_points/screens/admin_screen.dart';
import 'package:hamster_points/screens/buy_sell_screen.dart';
import 'package:hamster_points/screens/rare_animals_screen.dart';
import 'package:hamster_points/screens/crypto_screen.dart';
import 'package:hamster_points/screens/privacy_policy_screen.dart';
import 'package:hamster_points/screens/terms_of_service_screen.dart';
import 'package:hamster_points/screens/lucky_wheel_screen.dart';
import 'package:hamster_points/screens/staking_screen.dart';

import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/providers/locale_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/services/demo_service.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    developer.log(
      'Flutter Error: ${details.exceptionAsString()}',
      name: 'ITC Earn',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(() async {
    await DemoService().initialize();

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Please restart the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    };

    runApp(const MyApp());
  }, (error, stackTrace) {
    developer.log(
      'Zone Error: $error',
      name: 'ITC Earn',
      error: error,
      stackTrace: stackTrace,
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DemoProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'ITC Earn',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: '/splash',
            locale: localeProvider.locale,
            builder: (context, child) {
              return child!;
            },
            routes: {
              '/splash': (context) => SplashScreen(),
              '/onboarding': (context) => OnboardingScreen(),
              '/auth': (context) => AuthScreen(),
              '/home': (context) => HomeScreen(),
              '/tasks': (context) => TasksScreen(),
              '/market': (context) => MarketScreen(),
              '/farm': (context) => MyFarmScreen(),
              '/wallet': (context) => WalletScreen(),
              '/referral': (context) => ReferralScreen(),
              '/profile': (context) => ProfileScreen(),
              '/admin': (context) => AdminScreen(),
              '/privacy': (context) => PrivacyPolicyScreen(),
              '/terms': (context) => TermsOfServiceScreen(),
              '/wheel': (context) => LuckyWheelScreen(),
              '/staking': (context) => StakingScreen(),
              '/buy_sell': (context) => BuySellScreen(),
              '/rare_animals': (context) => RareAnimalsScreen(),
              '/crypto': (context) => CryptoScreen(),
            },
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
              Locale('fr', 'FR'),
            ],
          );
        },
      ),
    );
  }
}
