import 'package:flutter/material.dart';
import '../../../core/router/routes.dart';
import '../../roles/data/role_repository.dart';

class BuyerDetailsPage extends StatefulWidget {
  const BuyerDetailsPage({super.key});

  @override
  State<BuyerDetailsPage> createState() => _BuyerDetailsPageState();
}

class _BuyerDetailsPageState extends State<BuyerDetailsPage> {
  // Tab controllers
  final fullName = TextEditingController();
  String entityType = 'فرد';
  final phone = TextEditingController();

  Map<String, String>? registrationData;

  // Regions
  List<Map<String, dynamic>> regions = [];
  int? selectedRegionId;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final regionsList = await RoleRepository().getRegions();
      setState(() {
        regions = regionsList.map((r) => {'id': r.id, 'name': r.name}).toList();
      });
    } catch (e) {
      print('Error loading regions: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get data passed from registration
    final args = ModalRoute.of(context)?.settings.arguments;
    print('BuyerDetailsPage - Received arguments: $args');

    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        registrationData = Map<String, String>.from(
          args.map((key, value) => MapEntry(key, value.toString())),
        );

        print('BuyerDetailsPage - Parsed registrationData: $registrationData');

        // Pre-fill fields from registration data
        if (registrationData != null) {
          fullName.text = registrationData!['name'] ?? '';
          phone.text = registrationData!['phone'] ?? '';
          address.text = registrationData!['address'] ?? '';

          print('BuyerDetailsPage - Set fullName: ${fullName.text}');
          print('BuyerDetailsPage - Set phone: ${phone.text}');
          print('BuyerDetailsPage - Set address: ${address.text}');
        }
      });
    }
  }

  bool isActive = false; // نشط/غير نشط

  final address = TextEditingController();

  @override
  void dispose() {
    fullName.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
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
                    Image.asset('assets/images/logo.png', height: 64),
                    const SizedBox(height: 8),
                    Text(
                      'بيانات المشتري',
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
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                260,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Material(
                      elevation: 12,
                      borderRadius: BorderRadius.circular(20),
                      shadowColor: Colors.black.withOpacity(0.18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              labelColor: Theme.of(context).colorScheme.primary,
                              unselectedLabelColor: Colors.black54,
                              tabs: const [
                                Tab(text: 'البيانات الأساسية'),
                                Tab(text: 'التفاصيل'),
                                Tab(text: 'العنوان والحالة'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 320,
                              child: TabBarView(
                                children: [
                                  // Tab 1
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _label(context, 'اسم المشتري *'),
                                      _input(fullName, hint: 'اسم المشتري'),
                                      const SizedBox(height: 12),
                                      _label(context, 'نوع الكيان *'),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          ChoiceChip(
                                            label: const Text('فرد'),
                                            selected: entityType == 'فرد',
                                            onSelected: (_) => setState(
                                              () => entityType = 'فرد',
                                            ),
                                          ),
                                          ChoiceChip(
                                            label: const Text('شركة'),
                                            selected: entityType == 'شركة',
                                            onSelected: (_) => setState(
                                              () => entityType = 'شركة',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _label(context, 'رقم الجوال *'),
                                      _input(
                                        phone,
                                        hint: '05xxxxxxxx',
                                        keyboard: TextInputType.phone,
                                        ltr: true,
                                      ),
                                    ],
                                  ),
                                  // Tab 2
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _label(context, 'المنطقة *'),
                                      DropdownButtonFormField<int>(
                                        value: selectedRegionId,
                                        items: regions.map((region) {
                                          return DropdownMenuItem<int>(
                                            value: region['id'] as int,
                                            child: Text(
                                              region['name'] as String,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (v) => setState(
                                          () => selectedRegionId = v,
                                        ),
                                        decoration: _inputDecoration(),
                                      ),
                                    ],
                                  ),
                                  // Tab 3
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _label(context, 'الحالة'),
                                      Row(
                                        children: [
                                          Switch(
                                            value: isActive,
                                            onChanged: (v) =>
                                                setState(() => isActive = v),
                                            activeColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(isActive ? 'نشط' : 'غير نشط'),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _label(context, 'العنوان (اختياري)'),
                                      _input(
                                        address,
                                        hint: 'المدينة، الحي، الشارع',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (btnCtx) {
                                final ctrl = DefaultTabController.of(btnCtx);
                                return AnimatedBuilder(
                                  animation: ctrl,
                                  builder: (context, _) {
                                    final last = ctrl.length - 1;
                                    final isLast = ctrl.index == last;
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!isLast) {
                                            ctrl.animateTo(ctrl.index + 1);
                                          } else {
                                            try {
                                              // Convert isActive to API format
                                              String activeStatus = isActive
                                                  ? 'active'
                                                  : 'inactive';

                                              final payload = {
                                                'name': fullName.text.trim(),
                                                'jwal': phone.text.trim(),
                                                'address': address.text.trim(),
                                                'region_id':
                                                    selectedRegionId ?? 1,
                                                'active': activeStatus,
                                              };

                                              print('Buyer payload: $payload');
                                              await RoleRepository().saveBuyer(
                                                payload,
                                              );
                                              if (!btnCtx.mounted) return;
                                              Navigator.of(
                                                btnCtx,
                                              ).pushReplacementNamed(
                                                Routes.buyerHome,
                                              );
                                            } catch (e) {
                                              if (!btnCtx.mounted) return;
                                              ScaffoldMessenger.of(
                                                btnCtx,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'فشل الحفظ: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(isLast ? 'حفظ' : 'متابعة'),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext ctx, String t) =>
      Text(t, style: Theme.of(ctx).textTheme.labelLarge);

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
  );

  Widget _input(
    TextEditingController c, {
    required String hint,
    TextInputType? keyboard,
    bool ltr = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      decoration: _inputDecoration().copyWith(hintText: hint),
    );
  }
}
