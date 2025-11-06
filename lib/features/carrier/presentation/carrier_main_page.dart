import 'package:flutter/material.dart';
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: 'الشحنات',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'السجل',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        ),
      ),
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
