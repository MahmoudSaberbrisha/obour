import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/router/routes.dart';
import '../data/auth_repository.dart';

final userProfileProvider = FutureProvider<Map<String, String?>>((ref) async {
  final storage = SecureStorage();
  final userName = await storage.readUserName();
  final userEmail = await storage.readUserEmail();
  final idType = await storage.readIdentificationType();
  final idNumber = await storage.readIdentificationNumber();

  print('ProfilePage - userName from storage: $userName');
  print('ProfilePage - userEmail from storage: $userEmail');

  return {
    'userName': userName,
    'userEmail': userEmail,
    'identificationType': idType,
    'identificationNumber': idNumber,
  };
});

final userFullProfileProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repo = AuthRepository();
  try {
    final res = await repo.getMe();
    // Some APIs return { user: {...} }
    if (res['user'] is Map<String, dynamic>)
      return Map<String, dynamic>.from(res['user']);
    return Map<String, dynamic>.from(res);
  } catch (_) {
    return {};
  }
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                final repository = AuthRepository();
                await repository.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
                }
              }
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: profileAsync.when(
          data: (data) => DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: 'بيانات الحساب'),
                    Tab(text: 'بيانات الكيان'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [const _AccountInfoTab(), _EntityInfoTab()],
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('حدث خطأ في تحميل البيانات')),
        ),
      ),
    );
  }
}

class _AccountInfoTab extends ConsumerWidget {
  const _AccountInfoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basic = ref.watch(userProfileProvider).value ?? {};
    final full = ref.watch(userFullProfileProvider).value ?? {};

    final role = (full['role'] ?? full['person_type'] ?? '-').toString();
    final phone = (full['jwal'] ?? full['phone'] ?? '-').toString();
    final address = (full['address'] ?? '-').toString();
    final region = (full['Region']?['name'] ?? full['region']?['name'] ?? '-')
        .toString();
    final city = (full['City']?['name'] ?? full['city']?['name'] ?? '-')
        .toString();
    final status = (full['active'] ?? full['status'] ?? '-').toString();
    final createdAt = (full['createdAt'] ?? full['created_at'] ?? '-')
        .toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'اسم المستخدم',
          value: basic['userName'] ?? 'غير محدد',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'البريد الإلكتروني',
          value: basic['userEmail'] ?? 'غير محدد',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'الدور/الصفة',
          value: role.isEmpty ? '-' : role,
          icon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'رقم الجوال',
          value: phone.isEmpty ? '-' : phone,
          icon: Icons.phone_android_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'العنوان',
          value: address.isEmpty ? '-' : address,
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'المنطقة',
          value: region.isEmpty ? '-' : region,
          icon: Icons.map_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'المدينة',
          value: city.isEmpty ? '-' : city,
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'نوع الهوية',
          value: basic['identificationType'] ?? '-',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'رقم الهوية',
          value: basic['identificationNumber'] ?? '-',
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'حالة الحساب',
          value: status.isEmpty ? '-' : status,
          icon: Icons.shield_moon_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'تاريخ الإنشاء',
          value: createdAt.split('T').first,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                final repository = AuthRepository();
                await repository.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
                }
              }
            },
          ),
        ),
      ],
    );
  }
}

class _EntityInfoTab extends StatelessWidget {
  const _EntityInfoTab();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final data = ref.watch(userProfileProvider).value ?? {};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoCard(
              title: 'نوع الهوية',
              value: (data['identificationType'] ?? 'غير محدد'),
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'رقم الهوية',
              value: (data['identificationNumber'] ?? 'غير محدد'),
              icon: Icons.confirmation_number_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تمت إزالة تبويب عرض "كل البيانات" وإظهار كل الحقول داخل تبويب بيانات الحساب
