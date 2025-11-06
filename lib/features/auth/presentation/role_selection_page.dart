import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:ui' as ui;
import '../../../core/router/routes.dart';
import '../data/auth_repository.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  Map<String, String>? userData;
  Map<String, String> roleToType = {
    '/buyerDetails': 'client',
    '/supplierDetails': 'supplier',
    '/carrierDetails': 'carrier',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user data passed from registration
    final args = ModalRoute.of(context)?.settings.arguments;
    print('RoleSelectionPage - Received arguments: $args');

    if (args != null && args is Map<String, dynamic>) {
      userData = Map<String, String>.from(
        args.map((key, value) => MapEntry(key, value.toString())),
      );
      print('RoleSelectionPage - Parsed userData: $userData');
    }
  }

  Future<void> _createAccountAndNavigate(String route) async {
    if (userData == null) return;

    final personType = roleToType[route];
    if (personType == null) return;

    try {
      // Import AuthRepository
      final repository = AuthRepository();

      // Create the account with the correct person_type
      // Only include fields defined in the schema
      final payload = {
        'role_id': 1, // Required by backend controller
        'name': userData!['name'],
        'username': userData!['username'],
        'email': userData!['email'],
        'password': userData!['password'],
        'person_type': personType,
        'status': 'active', // Required by schema
        'photo': '', // Required by schema
      };

      // Add optional fields if they exist
      if (userData!['phone'] != null &&
          userData!['phone'].toString().isNotEmpty) {
        payload['phone'] = userData!['phone'];
      }
      if (userData!['address'] != null &&
          userData!['address'].toString().isNotEmpty) {
        payload['address'] = userData!['address'];
      }

      // Always add identification fields if they exist in userData
      final idType = userData!['identification_type'];
      final idNumber = userData!['identification_number'];

      print(
        'Checking identification fields: idType=$idType, idNumber=$idNumber',
      );

      if (idType != null && idType.toString().isNotEmpty) {
        payload['identification_type'] = idType;
        print('Added identification_type to payload: $idType');
      } else {
        print('identification_type is null or empty, skipping');
      }

      if (idNumber != null && idNumber.toString().isNotEmpty) {
        payload['identification_number'] = idNumber;
        print('Added identification_number to payload: $idNumber');
      } else {
        print('identification_number is null or empty, skipping');
      }

      print('Creating account with person_type: $personType');
      print('Full payload: $payload');
      print(
        'Identification type from userData: ${userData!['identification_type']}',
      );
      print(
        'Identification number from userData: ${userData!['identification_number']}',
      );
      await repository.register(payload);

      // Login to get token
      await repository.login(userData!['email']!, userData!['password']!);

      if (!mounted) return;

      // Navigate to role details page
      Navigator.of(context).pushReplacementNamed(route, arguments: userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      print('DioException creating account: $e');
      if (!mounted) return;

      String errorMessage = 'حدث خطأ أثناء إنشاء الحساب';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 500) {
          errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
          print('Server error details: $data');
        } else if (data != null && data['message'] != null) {
          errorMessage = data['message'];
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print('Error creating account: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      _RoleData(
        'ناقل',
        Icons.local_shipping_outlined,
        Colors.orange,
        Routes.carrierDetails,
      ),
      _RoleData(
        'مشتري',
        Icons.shopping_bag_outlined,
        Colors.blue,
        Routes.buyerDetails,
      ),
      _RoleData(
        'مورد',
        Icons.store_mall_directory_outlined,
        Colors.purple,
        Routes.supplierDetails,
      ),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Same top hero background as Login/Register
            SizedBox(
              height: 400,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/Rectangle 350.png',
                      fit: BoxFit.cover,
                    ),
                    Container(color: Colors.black.withOpacity(0.35)),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: 64,
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 44),
                    const SizedBox(height: 8),
                    Text(
                      'اختر نوع الحساب',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Card with tabs overlapping the hero
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 310, 16, 16),
              child: DefaultTabController(
                length: roles.length,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withOpacity(0.65),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                child: TabBar(
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.black54,
                                  tabs: roles
                                      .map(
                                        (role) => Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(role.icon, size: 20),
                                              const SizedBox(width: 8),
                                              Text(role.title),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Builder(
                                builder: (contentCtx) {
                                  final t = DefaultTabController.of(contentCtx);
                                  return AnimatedBuilder(
                                    animation: t,
                                    builder: (context, _) {
                                      final current = t.index;
                                      return AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        child: Container(
                                          key: ValueKey('tab$current'),
                                          child: _RoleTabContent(
                                            role: roles[current],
                                            userData: userData,
                                            onNavigate: () {
                                              _createAccountAndNavigate(
                                                roles[current].route,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleData {
  final String title;
  final IconData icon;
  final Color accent;
  final String route;
  _RoleData(this.title, this.icon, this.accent, this.route);
}

class _RoleTabContent extends StatelessWidget {
  final _RoleData role;
  final Map<String, String>? userData;
  final VoidCallback onNavigate;

  const _RoleTabContent({
    required this.role,
    required this.userData,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon and title
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: role.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: role.accent.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: role.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(role.icon, size: 64, color: role.accent),
              ),
              const SizedBox(height: 16),
              Text(
                role.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: role.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getRoleDescription(role.title),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Action button
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.85)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onNavigate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'متابعة كـ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    role.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getRoleDescription(String title) {
    switch (title) {
      case 'ناقل':
        return 'تسجيل كشركة نقل لتقديم خدمات التوصيل والشحن';
      case 'مشتري':
        return 'تسجيل كعميل لشراء المنتجات والخدمات من الموردين';
      case 'مورد':
        return 'تسجيل كمورد لتقديم المنتجات والخدمات للعملاء';
      default:
        return 'اختر نوع الحساب المناسب لك';
    }
  }
}
