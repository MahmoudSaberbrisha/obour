import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_notifier.dart';
import 'core/router/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/splash/presentation/splash_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/auth/presentation/role_selection_page.dart';
import 'features/auth/presentation/buyer_details_page.dart';
import 'features/auth/presentation/supplier_details_page.dart';
import 'features/auth/presentation/carrier_details_page.dart';
import 'features/buyer/presentation/buyer_main_page.dart';
import 'features/buyer/presentation/buyer_orders_page.dart';
import 'features/buyer/presentation/buyer_create_order_page.dart';
import 'features/supplier/presentation/supplier_main_page.dart';
import 'features/carrier/presentation/carrier_main_page.dart';
import 'features/admin/presentation/admin_main_page.dart';
import 'features/auth/presentation/home_page.dart';
import 'features/auth/presentation/profile_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Obour',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return const Locale('ar');
        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode) {
            return locale;
          }
        }
        return const Locale('ar');
      },
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashPage(),
        Routes.onboarding: (_) => const OnboardingPage(),
        Routes.login: (_) => const LoginPage(),
        Routes.register: (_) => const RegisterPage(),
        Routes.roleSelection: (_) => const RoleSelectionPage(),
        Routes.buyerDetails: (_) => const BuyerDetailsPage(),
        Routes.supplierDetails: (_) => const SupplierDetailsPage(),
        Routes.carrierDetails: (_) => const CarrierDetailsPage(),
        Routes.buyerHome: (_) => const BuyerMainPage(),
        Routes.buyerOrders: (_) => const BuyerOrdersPage(),
        Routes.buyerCreateOrder: (_) => const BuyerCreateOrderPage(),
        Routes.supplierHome: (_) => const SupplierMainPage(),
        Routes.carrierHome: (_) => const CarrierMainPage(),
        Routes.adminHome: (_) => const AdminMainPage(),
        Routes.home: (_) => const HomePage(),
        Routes.profile: (_) => const ProfilePage(),
      },
    );
  }
}
