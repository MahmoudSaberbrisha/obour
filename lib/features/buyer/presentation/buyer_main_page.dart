import 'package:flutter/material.dart';
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.05),
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
            backgroundColor: Colors.white,
            indicatorColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: const Icon(Icons.shopping_bag_outlined),
                selectedIcon: const Icon(Icons.shopping_bag),
                label: 'الطلبات',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        ),
      ),
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
