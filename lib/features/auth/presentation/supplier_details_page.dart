import 'package:flutter/material.dart';
import '../../../core/router/routes.dart';
import '../../../core/storage/secure_storage.dart';
import '../../roles/data/role_repository.dart';

class SupplierDetailsPage extends StatefulWidget {
  const SupplierDetailsPage({super.key});

  @override
  State<SupplierDetailsPage> createState() => _SupplierDetailsPageState();
}

class _SupplierDetailsPageState extends State<SupplierDetailsPage> {
  final supplierName = TextEditingController();
  String supplierType = '';
  final idNumber = TextEditingController();

  final _storage = SecureStorage();

  final phone = TextEditingController();
  int? selectedRegionId;

  final address = TextEditingController();
  bool isActive = false; // غير نشط افتراضياً

  Map<String, String>? registrationData;

  // Regions
  List<Map<String, dynamic>> regions = [];

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    try {
      final storedIdNumber = await _storage.readIdentificationNumber();
      if (storedIdNumber != null && storedIdNumber.isNotEmpty) {
        setState(() {
          idNumber.text = storedIdNumber;
        });
        print(
          'SupplierDetailsPage - Loaded identification_number from storage: $storedIdNumber',
        );
      }
    } catch (e) {
      print('Error loading stored data: $e');
    }
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        registrationData = Map<String, String>.from(
          args.map((key, value) => MapEntry(key, value.toString())),
        );
        if (registrationData != null) {
          supplierName.text = registrationData!['name'] ?? '';
          phone.text = registrationData!['phone'] ?? '';
          address.text = registrationData!['address'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    supplierName.dispose();
    idNumber.dispose();
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
                    Image.asset('assets/images/logo.png', height: 44),
                    const SizedBox(height: 8),
                    Text(
                      'بيانات المورد',
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
                                Tab(text: 'الأساسية'),
                                Tab(text: 'التواصل والمنطقة'),
                                Tab(text: 'العنوان والحالة'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 320,
                              child: TabBarView(
                                children: [
                                  // Tab 1 الأساسية
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _label(context, 'اسم المورد *'),
                                      _input(supplierName, hint: 'اسم المورد'),
                                      const SizedBox(height: 12),
                                      _label(context, 'نوع المورد *'),
                                      DropdownButtonFormField<String>(
                                        value: supplierType.isEmpty
                                            ? null
                                            : supplierType,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'فرد',
                                            child: Text('فرد'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'شركة',
                                            child: Text('شركة'),
                                          ),
                                        ],
                                        onChanged: (v) => setState(
                                          () => supplierType = v ?? '',
                                        ),
                                        decoration: _decoration(),
                                      ),
                                      const SizedBox(height: 12),
                                      _label(context, 'رقم الهوية *'),
                                      _input(
                                        idNumber,
                                        hint: 'رقم الهوية',
                                        keyboard: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  // Tab 2 التواصل والمنطقة
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _label(context, 'رقم الجوال *'),
                                      _input(
                                        phone,
                                        hint: '05xxxxxxxx',
                                        keyboard: TextInputType.phone,
                                        ltr: true,
                                      ),
                                      const SizedBox(height: 12),
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
                                        decoration: _decoration(),
                                      ),
                                    ],
                                  ),
                                  // Tab 3 العنوان والحالة
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _label(context, 'العنوان *'),
                                      _input(
                                        address,
                                        hint: 'المدينة، الحي، الشارع',
                                      ),
                                      const SizedBox(height: 12),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (btnCtx) {
                                final ctrl = DefaultTabController.of(btnCtx);
                                if (ctrl == null)
                                  return const SizedBox.shrink();
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
                                              // Convert supplierType to API format
                                              String supplierTypeApi =
                                                  supplierType == 'فرد'
                                                  ? 'person'
                                                  : 'company';

                                              // Convert isActive to API format
                                              String activeStatus = isActive
                                                  ? 'active'
                                                  : 'inactive';

                                              final payload = {
                                                'name': supplierName.text
                                                    .trim(),
                                                'supplier_type':
                                                    supplierTypeApi,
                                                'identification_number':
                                                    idNumber.text.trim(),
                                                'identification_type':
                                                    'card', // Default to card
                                                'jwal': phone.text.trim(),
                                                'address': address.text.trim(),
                                                'region_id':
                                                    selectedRegionId ?? 1,
                                                'active': activeStatus,
                                              };

                                              print(
                                                'Supplier payload: $payload',
                                              );
                                              await RoleRepository()
                                                  .saveSupplier(payload);
                                              if (!btnCtx.mounted) return;
                                              Navigator.of(
                                                btnCtx,
                                              ).pushReplacementNamed(
                                                Routes.supplierHome,
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
  InputDecoration _decoration() => InputDecoration(
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
      decoration: _decoration().copyWith(hintText: hint),
    );
  }
}
