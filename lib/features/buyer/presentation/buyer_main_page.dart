import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_mode.dart';
import 'buyer_home_page.dart';
import 'buyer_orders_page.dart';
import '../../auth/presentation/profile_page.dart';
import '../../../core/router/routes.dart';
import '../../auth/data/auth_repository.dart';

class BuyerMainPage extends StatefulWidget {
  const BuyerMainPage({super.key});

  @override
  State<BuyerMainPage> createState() => _BuyerMainPageState();
}

class _BuyerMainPageState extends State<BuyerMainPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BuyerHomePage(),
    const BuyerOrdersPageWrapper(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: isDark ? 10 : 4,
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            ),
          ],
        ),
        child: ClipRRect(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            height: 70,
            elevation: 0,
            backgroundColor: colors.surface.withOpacity(isDark ? 0.9 : 1),
            indicatorColor: colors.primary.withOpacity(0.18),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: l10n.translate('navHome'),
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: l10n.translate('navBuyerOrders'),
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: l10n.translate('navBuyerProfile'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const ThemeModeToggleFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class BuyerOrdersPageWrapper extends StatelessWidget {
  const BuyerOrdersPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const BuyerOrdersPage();
  }
}
