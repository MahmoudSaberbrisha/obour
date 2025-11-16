import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_mode.dart';
import 'carrier_home_page.dart';
import '../../auth/presentation/profile_page.dart';

class CarrierMainPage extends StatefulWidget {
  const CarrierMainPage({super.key});

  @override
  State<CarrierMainPage> createState() => _CarrierMainPageState();
}

class _CarrierMainPageState extends State<CarrierMainPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CarrierHomePage(),
    const _ShipmentsPage(),
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
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: l10n.translate('navCarrierShipments'),
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: l10n.translate('navCarrierHistory'),
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: l10n.translate('navCarrierProfile'),
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

class _ShipmentsPage extends StatelessWidget {
  const _ShipmentsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('السجل'),
      ),
      body: const Center(child: Text('صفحة السجل')),
    );
  }
}
