import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/presentation/profile_page.dart';
import 'admin_providers.dart';

final adminUserNameProvider = FutureProvider<String?>((ref) async {
  final storage = SecureStorage();
  return await storage.readUserName();
});

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardPage(),
    const _UsersPage(),
    const _OrdersPage(),
    const _ReportsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.98),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -4),
                blurRadius: 20,
                spreadRadius: 0,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
              ),
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 20,
                spreadRadius: 0,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.98),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                height: 74,
                elevation: 10,
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                animationDuration: const Duration(milliseconds: 800),
                surfaceTintColor: Colors.transparent,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.9,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  }
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 0.9,
                    color: Colors.grey[700],
                  );
                }),
                destinations: [
                  _ModernNavDestination(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: 'لوحة التحكم',
                    isSelected: _currentIndex == 0,
                  ),
                  _ModernNavDestination(
                    icon: Icons.people_outline,
                    selectedIcon: Icons.people,
                    label: 'المستخدمون',
                    isSelected: _currentIndex == 1,
                  ),
                  _ModernNavDestination(
                    icon: Icons.shopping_cart_outlined,
                    selectedIcon: Icons.shopping_cart,
                    label: 'الطلبات',
                    isSelected: _currentIndex == 2,
                  ),
                  _ModernNavDestination(
                    icon: Icons.analytics_outlined,
                    selectedIcon: Icons.analytics,
                    label: 'التقارير',
                    isSelected: _currentIndex == 3,
                  ),
                  _ModernNavDestination(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'الملف الشخصي',
                    isSelected: _currentIndex == 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _chip(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _infoTile(String label, String value) {
  return Container(
    width: 170,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _DashboardPage extends ConsumerWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNameAsync = ref.watch(adminUserNameProvider);
    final suppliersAsync = ref.watch(adminSuppliersListProvider);
    final clientsAsync = ref.watch(adminClientsListProvider);
    final carriersAsync = ref.watch(adminCarriersListProvider);
    final ordersAsync = ref.watch(adminOrdersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        automaticallyImplyLeading: false,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userNameAsync.when(
                data: (name) => Text(
                  'مرحباً بك ${name ?? ''}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => Text(
                  'مرحباً بك',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                error: (_, __) => Text(
                  'مرحباً بك',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Stats Grid
              if (suppliersAsync is AsyncData &&
                  clientsAsync is AsyncData &&
                  carriersAsync is AsyncData &&
                  ordersAsync is AsyncData)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _EnhancedStatCard(
                            icon: Icons.store,
                            title: 'إجمالي الموردين',
                            value: (suppliersAsync.value?.length ?? 0)
                                .toString(),
                            subtitle:
                                '${(suppliersAsync.value ?? []).where((s) => s['active'] == 'active').length} نشط',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EnhancedStatCard(
                            icon: Icons.shopping_cart,
                            title: 'إجمالي المشترين',
                            value: (clientsAsync.value?.length ?? 0).toString(),
                            subtitle:
                                '${(clientsAsync.value ?? []).where((c) => c['active'] == 'active').length} نشط',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _EnhancedStatCard(
                            icon: Icons.local_shipping,
                            title: 'إجمالي الناقلين',
                            value: (carriersAsync.value?.length ?? 0)
                                .toString(),
                            subtitle:
                                '${(carriersAsync.value ?? []).where((c) => c['active'] == 'active').length} نشط',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EnhancedStatCard(
                            icon: Icons.shopping_bag,
                            title: 'إجمالي الطلبات',
                            value: (ordersAsync.value?.length ?? 0).toString(),
                            subtitle:
                                '${(ordersAsync.value ?? []).where((o) => o['status'] == 'completed').length} مكتمل',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _EnhancedStatCard(
                            icon: Icons.hourglass_empty,
                            title: 'الطلبات قيد التنفيذ',
                            value:
                                '${(ordersAsync.value ?? []).where((o) => o['status'] == 'in_progress' || o['status'] == 'processing').length}',
                            subtitle:
                                '${(ordersAsync.value ?? []).where((o) => o['status'] == 'pending').length} في الانتظار',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EnhancedStatCard(
                            icon: Icons.verified,
                            title: 'الموردين النشطين',
                            value:
                                '${(suppliersAsync.value ?? []).where((s) => s['active'] == 'active').length}',
                            subtitle:
                                '${(suppliersAsync.value ?? []).where((s) => s['active'] == 'inactive').length} غير نشط',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Charts Row
                    Row(
                      children: [
                        Expanded(
                          child: _OrderStatusChart(
                            orders: ordersAsync.value ?? [],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActivitySummary(
                            suppliers: suppliersAsync.value ?? [],
                            clients: clientsAsync.value ?? [],
                            carriers: carriersAsync.value ?? [],
                            orders: ordersAsync.value ?? [],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Bottom Row - Regions and Recent Activities
                    Row(
                      children: [
                        Expanded(
                          child: _TopRegions(
                            suppliers: suppliersAsync.value ?? [],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RecentActivities(
                            orders: ordersAsync.value ?? [],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _EnhancedStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusChart extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const _OrderStatusChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    final statusCounts = <String, int>{};
    for (final order in orders) {
      final status = order['status']?.toString() ?? 'unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    final total = orders.length;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(child: Text('لا توجد بيانات')),
      );
    }

    final chartData = [
      {
        'status': 'مكتملة',
        'count': statusCounts['completed'] ?? 0,
        'color': Colors.green,
      },
      {
        'status': 'قيد التنفيذ',
        'count':
            (statusCounts['in_delivery'] ?? 0) +
            (statusCounts['in_progress'] ?? 0) +
            (statusCounts['processing'] ?? 0),
        'color': Colors.orange,
      },
      {
        'status': 'قيد المراجعة',
        'count':
            (statusCounts['initial'] ?? 0) + (statusCounts['pending'] ?? 0),
        'color': Colors.blue,
      },
      {
        'status': 'ملغاة',
        'count': statusCounts['cancelled'] ?? 0,
        'color': Colors.red,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلبات',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: chartData.map((data) {
                  final percentage = ((data['count'] as int) / total) * 100;
                  return PieChartSectionData(
                    value: (data['count'] as int).toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: data['color'] as Color,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: chartData.map((data) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${data['status']}: ${data['count']}'),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActivitySummary extends StatelessWidget {
  final List<Map<String, dynamic>> suppliers;
  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> carriers;
  final List<Map<String, dynamic>> orders;

  const _ActivitySummary({
    required this.suppliers,
    required this.clients,
    required this.carriers,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final activeSuppliers = suppliers
        .where((s) => s['active'] == 'active')
        .length;
    final activeClients = clients.where((c) => c['active'] == 'active').length;
    final activeCarriers = carriers
        .where((c) => c['active'] == 'active')
        .length;
    final totalActive = activeSuppliers + activeClients + activeCarriers;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص النشاط',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _SummaryItem(
            icon: Icons.store,
            label: 'الموردين',
            value: activeSuppliers.toString(),
            total: suppliers.length.toString(),
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _SummaryItem(
            icon: Icons.shopping_cart,
            label: 'المشترين',
            value: activeClients.toString(),
            total: clients.length.toString(),
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _SummaryItem(
            icon: Icons.local_shipping,
            label: 'الناقلين',
            value: activeCarriers.toString(),
            total: carriers.length.toString(),
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي النشطين',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$totalActive',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String total;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          '$value/$total',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TopRegions extends StatelessWidget {
  final List<Map<String, dynamic>> suppliers;

  const _TopRegions({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final regionCounts = <String, int>{};
    for (final supplier in suppliers) {
      final region =
          supplier['region']?['name']?.toString() ??
          supplier['name']?.toString() ??
          'غير محدد';
      regionCounts[region] = (regionCounts[region] ?? 0) + 1;
    }

    final sortedRegions = regionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topRegions = sortedRegions.take(5).toList();

    if (topRegions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(child: Text('لا توجد بيانات')),
      );
    }

    final total = topRegions.fold<int>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أكثر المناطق نشاطاً',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...topRegions.map((region) {
            final percentage = (region.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${topRegions.indexOf(region) + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          region.key,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${region.value} مورد',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _RecentActivities extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const _RecentActivities({required this.orders});

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'مكتمل';
      case 'in_progress':
      case 'processing':
        return 'قيد التنفيذ';
      case 'pending':
      case 'initial':
        return 'قيد المراجعة';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'جديد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'processing':
        return Colors.orange;
      case 'pending':
      case 'initial':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentOrders = orders.take(4).toList();

    if (recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(child: Text('لا توجد نشاطات')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'النشاطات الأخيرة',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...recentOrders.map((order) {
            final status = order['status']?.toString();
            final statusText = _getStatusText(status);
            final statusColor = _getStatusColor(status);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب #${order['id'] ?? order['order_number'] ?? '-'}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'من: ${order['supplier_name'] ?? 'غير محدد'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _UsersPage extends ConsumerWidget {
  const _UsersPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('المستخدمون'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'المستخدمون'),
              Tab(text: 'الناقلون'),
              Tab(text: 'الموردون'),
              Tab(text: 'العملاء'),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: const TabBarView(
            children: [
              _UsersListTab(),
              _CarriersListTab(),
              _SuppliersListTab(),
              _ClientsListTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersListTab extends ConsumerWidget {
  const _UsersListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminUsersListProvider);
    return asyncList.when(
      data: (items) =>
          _EntityList(items: items, titleKey: 'name', subtitleKey: 'email'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}

class _ClientsListTab extends ConsumerWidget {
  const _ClientsListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminClientsListProvider);
    return asyncList.when(
      data: (items) =>
          _EntityList(items: items, titleKey: 'name', subtitleKey: 'jwal'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}

class _CarriersListTab extends ConsumerWidget {
  const _CarriersListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminCarriersListProvider);
    return asyncList.when(
      data: (items) =>
          _EntityList(items: items, titleKey: 'name', subtitleKey: 'jwal'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}

class _SuppliersListTab extends ConsumerWidget {
  const _SuppliersListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminSuppliersListProvider);
    return asyncList.when(
      data: (items) =>
          _EntityList(items: items, titleKey: 'name', subtitleKey: 'jwal'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}

class _EntityList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String titleKey;
  final String subtitleKey;
  const _EntityList({
    required this.items,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }
    final hasActiveKey = items.first.containsKey('active');
    final total = items.length;
    final activeCount = hasActiveKey
        ? items.where((e) => (e['active'] == 'active')).length
        : null;
    final inactiveCount = hasActiveKey ? (total - (activeCount ?? 0)) : null;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                icon: Icons.people_outline,
                title: 'الإجمالي',
                value: total.toString(),
                progress: 1,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProgressCard(
                icon: Icons.verified,
                title: 'نشط',
                value: hasActiveKey ? (activeCount?.toString() ?? '0') : '-',
                progress: hasActiveKey && total > 0
                    ? (activeCount! / total)
                    : 0,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                icon: Icons.pause_circle_outline,
                title: 'غير نشط',
                value: hasActiveKey ? (inactiveCount?.toString() ?? '0') : '-',
                progress: hasActiveKey && total > 0
                    ? (inactiveCount! / total)
                    : 0,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map(
          (it) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text('${it[titleKey] ?? '-'}'),
              subtitle: Text('${it[subtitleKey] ?? '-'}'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (_) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.75,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (context, controller) {
                        final isActive = (it['active'] == 'active');
                        final role = (it['role'] ?? it['person_type'] ?? '-')
                            .toString();
                        final phone = (it['jwal'] ?? it['phone'] ?? '-')
                            .toString();
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            controller: controller,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        (isActive ? Colors.green : Colors.grey)
                                            .withOpacity(0.12),
                                    child: Icon(
                                      Icons.person,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${it[titleKey] ?? '-'}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: [
                                            _chip(
                                              isActive ? 'نشط' : 'غير نشط',
                                              isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            if (role.isNotEmpty && role != '-')
                                              _chip(role, Colors.blue),
                                            if (phone.isNotEmpty &&
                                                phone != '-')
                                              _chip(
                                                'جوال: $phone',
                                                Colors.orange,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Key info grid (selected fields only)
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  if ((it['email'] ?? '').toString().isNotEmpty)
                                    _infoTile(
                                      'البريد الإلكتروني',
                                      '${it['email']}',
                                    ),
                                  if ((it['jwal'] ?? it['phone'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    _infoTile(
                                      'الجوال',
                                      '${it['jwal'] ?? it['phone']}',
                                    ),
                                  if ((it['city'] ?? '').toString().isNotEmpty)
                                    _infoTile('المدينة', '${it['city']}'),
                                  if ((it['region'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    _infoTile('المنطقة', '${it['region']}'),
                                  if ((it['createdAt'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    _infoTile(
                                      'تاريخ الإنشاء',
                                      '${it['createdAt']}',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              // Curated full details with Arabic labels
                              ...(() {
                                final List<MapEntry<String, String>> details =
                                    [];
                                void add(String label, dynamic value) {
                                  final v = (value == null)
                                      ? ''
                                      : value.toString();
                                  if (v.trim().isEmpty ||
                                      v == '-' ||
                                      v == 'null')
                                    return;
                                  details.add(MapEntry(label, v));
                                }

                                add('الاسم', it[titleKey] ?? it['name']);
                                add('البريد الإلكتروني', it['email']);
                                add('الجوال', it['jwal'] ?? it['phone']);
                                add('الدور', it['role'] ?? it['person_type']);
                                add('الحالة', isActive ? 'نشط' : 'غير نشط');
                                add('المدينة', it['city']);
                                add('المنطقة', it['region']);
                                add('العنوان', it['address']);
                                add('رقم الهوية', it['identification_number']);
                                add('نوع الهوية', it['identification_type']);
                                add('تاريخ الإنشاء', it['createdAt']);
                                add('آخر تحديث', it['updatedAt']);

                                // لبعض الأنواع: المورد/الناقل قد يملكون اسم مؤسسة
                                add(
                                  'اسم المؤسسة',
                                  it['institution_name'] ?? it['company_name'],
                                );

                                return details.map(
                                  (e) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          child: Text(
                                            e.key,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            e.value,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _OrdersPage extends ConsumerWidget {
  const _OrdersPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersListProvider);
    final dio = ApiClient.build();

    Future<List<Map<String, dynamic>>> fetchProducts() async {
      try {
        final res = await dio.get('/products');
        final data = res.data;
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data['products'] is List) {
          return (data['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data is Map && data['data']?['products'] is List) {
          return (data['data']['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      } catch (_) {}
      return [];
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('الطلبات'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ordersAsync.when(
          data: (orders) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                final products = snapshot.data ?? const [];
                if (orders.isEmpty &&
                    snapshot.connectionState != ConnectionState.waiting &&
                    products.isEmpty) {
                  return const Center(child: Text('لا توجد طلبات أو منتجات'));
                }
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.green,
                        tabs: [
                          Tab(text: 'الطلبات'),
                          Tab(text: 'المنتجات'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Orders tab
                            ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                if (orders.isEmpty)
                                  const Text('لا توجد طلبات')
                                else
                                  ...orders.map(
                                    (order) => InkWell(
                                      onTap: () {
                                        final status = order['status']
                                            ?.toString();
                                        final statusText = _getStatusText(
                                          status,
                                        );
                                        final statusColor = _getStatusColor(
                                          status ?? '',
                                        );
                                        showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          isScrollControlled: true,
                                          builder: (_) {
                                            final orderId =
                                                order['order_number'] ??
                                                order['id'] ??
                                                '-';
                                            final buyer =
                                                order['Buyer']?['name'] ??
                                                order['buyer_name'] ??
                                                '-';
                                            final supplier =
                                                order['Supplier']?['name'] ??
                                                order['supplier_name'] ??
                                                '-';
                                            final total =
                                                order['total_price']
                                                    ?.toString() ??
                                                '-';
                                            final date =
                                                order['order_date'] ??
                                                order['createdAt'] ??
                                                '-';
                                            return DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: 0.75,
                                              minChildSize: 0.5,
                                              maxChildSize: 0.95,
                                              builder: (context, controller) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: ListView(
                                                    controller: controller,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 24,
                                                            backgroundColor:
                                                                statusColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.12,
                                                                    ),
                                                            child: Icon(
                                                              _getStatusIcon(
                                                                status ?? '',
                                                              ),
                                                              color:
                                                                  statusColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'طلب #$orderId',
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.titleLarge,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Wrap(
                                                                  spacing: 8,
                                                                  runSpacing: 6,
                                                                  children: [
                                                                    _chip(
                                                                      statusText,
                                                                      statusColor,
                                                                    ),
                                                                    if (buyer !=
                                                                        '-')
                                                                      _chip(
                                                                        'المشتري: $buyer',
                                                                        Colors
                                                                            .blue,
                                                                      ),
                                                                    if (supplier !=
                                                                        '-')
                                                                      _chip(
                                                                        'المورد: $supplier',
                                                                        Colors
                                                                            .orange,
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Wrap(
                                                        spacing: 12,
                                                        runSpacing: 12,
                                                        children: [
                                                          _infoTile(
                                                            'الإجمالي',
                                                            total,
                                                          ),
                                                          _infoTile(
                                                            'التاريخ',
                                                            date.toString(),
                                                          ),
                                                          _infoTile(
                                                            'الحالة',
                                                            statusText,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Divider(
                                                        color: Colors.grey[300],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      ...(() {
                                                        final List<
                                                          MapEntry<
                                                            String,
                                                            String
                                                          >
                                                        >
                                                        details = [];
                                                        void add(
                                                          String label,
                                                          dynamic value,
                                                        ) {
                                                          final v =
                                                              (value == null)
                                                              ? ''
                                                              : value
                                                                    .toString();
                                                          if (v
                                                                  .trim()
                                                                  .isEmpty ||
                                                              v == '-' ||
                                                              v == 'null')
                                                            return;
                                                          details.add(
                                                            MapEntry(label, v),
                                                          );
                                                        }

                                                        add(
                                                          'رقم الطلب',
                                                          order['order_number'] ??
                                                              order['id'],
                                                        );
                                                        add(
                                                          'الحالة',
                                                          statusText,
                                                        );
                                                        add(
                                                          'المشتري',
                                                          order['Buyer']?['name'] ??
                                                              order['buyer_name'],
                                                        );
                                                        add(
                                                          'المورد',
                                                          order['Supplier']?['name'] ??
                                                              order['supplier_name'],
                                                        );
                                                        add(
                                                          'الإجمالي',
                                                          order['total_price'],
                                                        );
                                                        add(
                                                          'التاريخ',
                                                          order['order_date'] ??
                                                              order['createdAt'],
                                                        );
                                                        add(
                                                          'طريقة الدفع',
                                                          order['payment_method'] ??
                                                              order['paymentMethod'],
                                                        );
                                                        add(
                                                          'المدينة',
                                                          order['city'],
                                                        );
                                                        add(
                                                          'المنطقة',
                                                          order['region'],
                                                        );
                                                        add(
                                                          'العنوان',
                                                          order['address'],
                                                        );
                                                        add(
                                                          'ملاحظات',
                                                          order['notes'] ??
                                                              order['note'],
                                                        );
                                                        add(
                                                          'عدد العناصر',
                                                          order['items'] is List
                                                              ? (order['items']
                                                                        as List)
                                                                    .length
                                                              : order['items_count'],
                                                        );
                                                        return details.map(
                                                          (e) => Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  bottom: 8,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .grey[200]!,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 110,
                                                                  child: Text(
                                                                    e.key,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    e.value,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      })(),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: _getStatusColor(
                                              order['status'] ?? '',
                                            ).withOpacity(0.1),
                                            child: Icon(
                                              _getStatusIcon(
                                                order['status'] ?? '',
                                              ),
                                              color: _getStatusColor(
                                                order['status'] ?? '',
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            'رقم الطلب: ${order['order_number'] ?? '-'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'الحالة: ${order['status'] ?? '-'}',
                                              ),
                                              if (order['total_price'] != null)
                                                Text(
                                                  'المبلغ: ${order['total_price']}',
                                                ),
                                              if (order['order_date'] != null)
                                                Text(
                                                  'التاريخ: ${order['order_date']}',
                                                ),
                                            ],
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Products tab
                            ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (products.isEmpty)
                                  const Text('لا توجد منتجات')
                                else
                                  ...products.map(
                                    (p) => InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          isScrollControlled: true,
                                          builder: (_) {
                                            final productName =
                                                p['name'] ?? '-';
                                            final price =
                                                p['price'] ??
                                                p['unit_price'] ??
                                                '-';
                                            final status =
                                                p['status'] ?? 'غير محدد';
                                            return DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: 0.75,
                                              minChildSize: 0.5,
                                              maxChildSize: 0.95,
                                              builder: (context, controller) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: ListView(
                                                    controller: controller,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 24,
                                                            backgroundColor:
                                                                Colors.green
                                                                    .withValues(
                                                                      alpha:
                                                                          0.12,
                                                                    ),
                                                            child: const Icon(
                                                              Icons
                                                                  .inventory_2_outlined,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  productName,
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.titleLarge,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Wrap(
                                                                  spacing: 8,
                                                                  runSpacing: 6,
                                                                  children: [
                                                                    _chip(
                                                                      'الحالة: $status',
                                                                      Colors
                                                                          .blue,
                                                                    ),
                                                                    if (price !=
                                                                        '-')
                                                                      _chip(
                                                                        'السعر: $price',
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Wrap(
                                                        spacing: 12,
                                                        runSpacing: 12,
                                                        children: [
                                                          if (price != '-')
                                                            _infoTile(
                                                              'السعر',
                                                              price.toString(),
                                                            ),
                                                          if (status !=
                                                              'غير محدد')
                                                            _infoTile(
                                                              'الحالة',
                                                              status.toString(),
                                                            ),
                                                          if (p['description'] !=
                                                              null)
                                                            _infoTile(
                                                              'الوصف',
                                                              p['description']
                                                                  .toString(),
                                                            ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Divider(
                                                        color: Colors.grey[300],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      ...(() {
                                                        final List<
                                                          MapEntry<
                                                            String,
                                                            String
                                                          >
                                                        >
                                                        details = [];
                                                        void add(
                                                          String label,
                                                          dynamic value,
                                                        ) {
                                                          final v =
                                                              (value == null)
                                                              ? ''
                                                              : value
                                                                    .toString();
                                                          if (v
                                                                  .trim()
                                                                  .isEmpty ||
                                                              v == '-' ||
                                                              v == 'null')
                                                            return;
                                                          details.add(
                                                            MapEntry(label, v),
                                                          );
                                                        }

                                                        add('الاسم', p['name']);
                                                        add(
                                                          'السعر',
                                                          p['price'] ??
                                                              p['unit_price'],
                                                        );
                                                        add(
                                                          'الحالة',
                                                          p['status'],
                                                        );
                                                        add(
                                                          'الوصف',
                                                          p['description'],
                                                        );
                                                        add(
                                                          'الكمية المتاحة',
                                                          p['stock'] ??
                                                              p['quantity'] ??
                                                              p['available_quantity'],
                                                        );
                                                        add(
                                                          'الكمية المباعة',
                                                          p['sold_quantity'],
                                                        );
                                                        add(
                                                          'الفئة',
                                                          p['category'] ??
                                                              p['category_name'],
                                                        );
                                                        add(
                                                          'المورد',
                                                          p['Supplier']?['name'] ??
                                                              p['supplier_name'],
                                                        );
                                                        add(
                                                          'تاريخ الإنشاء',
                                                          p['createdAt'],
                                                        );
                                                        add(
                                                          'آخر تحديث',
                                                          p['updatedAt'],
                                                        );
                                                        return details.map(
                                                          (e) => Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  bottom: 8,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .grey[200]!,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 110,
                                                                  child: Text(
                                                                    e.key,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    e.value,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      })(),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2_outlined,
                                              color: Colors.green,
                                            ),
                                          ),
                                          title: Text(
                                            '${p['name'] ?? '-'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'السعر: ${p['price'] ?? p['unit_price'] ?? '-'} • الحالة: ${(p['status'] ?? 'غير محدد')}',
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'مكتمل';
      case 'in_progress':
      case 'processing':
      case 'in_delivery':
        return 'قيد التنفيذ';
      case 'pending':
      case 'initial':
        return 'قيد المراجعة';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'جديد';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'مكتمل':
        return Colors.green;
      case 'pending':
      case 'initial':
      case 'جاهزة':
        return Colors.orange;
      case 'cancelled':
      case 'ملغى':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'مكتمل':
        return Icons.check_circle;
      case 'pending':
      case 'initial':
      case 'جاهزة':
        return Icons.pending;
      case 'cancelled':
      case 'ملغى':
        return Icons.cancel;
      default:
        return Icons.shopping_cart;
    }
  }
}

class _ReportsPage extends ConsumerWidget {
  const _ReportsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersListProvider);
    final suppliersAsync = ref.watch(adminSuppliersListProvider);
    final clientsAsync = ref.watch(adminClientsListProvider);
    final carriersAsync = ref.watch(adminCarriersListProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('التقارير'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ordersAsync.when(
          data: (orders) {
            final suppliers = suppliersAsync.value ?? [];
            final clients = clientsAsync.value ?? [];
            final carriers = carriersAsync.value ?? [];

            // Calculate statistics
            final totalReports = orders.length;
            final completedReports = orders
                .where((o) => o['status'] == 'completed')
                .length;
            final processingReports = orders
                .where(
                  (o) =>
                      o['status'] == 'in_delivery' ||
                      o['status'] == 'in_progress' ||
                      o['status'] == 'processing',
                )
                .length;
            final pendingReports = orders
                .where(
                  (o) => o['status'] == 'initial' || o['status'] == 'pending',
                )
                .length;

            final completionRate = totalReports > 0
                ? (completedReports / totalReports * 100).toInt()
                : 0;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إدارة التقارير',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'مركز شامل لإدارة ومراقبة جميع تقاريرك',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.filter_list),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Progress Overview
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.1),
                                Colors.green.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'معدل الإنجاز الإجمالي',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '$completionRate%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: completionRate / 100,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _MiniStat(
                                    label: 'مكتمل',
                                    value: completedReports.toString(),
                                    color: Colors.green,
                                  ),
                                  _MiniStat(
                                    label: 'قيد التنفيذ',
                                    value: processingReports.toString(),
                                    color: Colors.orange,
                                  ),
                                  _MiniStat(
                                    label: 'قيد المراجعة',
                                    value: pendingReports.toString(),
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Dashboard Statistics
                        Row(
                          children: [
                            Expanded(
                              child: _ProgressCard(
                                icon: Icons.description,
                                title: 'إجمالي التقارير',
                                value: totalReports.toString(),
                                progress: 1.0,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProgressCard(
                                icon: Icons.check_circle,
                                title: 'المكتملة',
                                value: completedReports.toString(),
                                progress: totalReports > 0
                                    ? completedReports / totalReports
                                    : 0,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ProgressCard(
                                icon: Icons.schedule,
                                title: 'قيد المعالجة',
                                value: processingReports.toString(),
                                progress: totalReports > 0
                                    ? processingReports / totalReports
                                    : 0,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProgressCard(
                                icon: Icons.access_time,
                                title: 'قيد المراجعة',
                                value: pendingReports.toString(),
                                progress: totalReports > 0
                                    ? pendingReports / totalReports
                                    : 0,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Report Categories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'فئات التقارير',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.grid_view, size: 18),
                              label: Text('عرض الكل'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final categories = [
                        {
                          'title': 'تقارير الطلبات',
                          'description': 'تحليل أداء الطلبات والمبيعات',
                          'count': orders.length.toString(),
                          'icon': Icons.shopping_cart,
                          'color': Colors.green,
                        },
                        {
                          'title': 'تقارير الموردين',
                          'description': 'تقييم وأداء شبكة الموردين',
                          'count': suppliers.length.toString(),
                          'icon': Icons.store,
                          'color': Colors.blue,
                        },
                        {
                          'title': 'تقارير العملاء',
                          'description': 'أداء وسلوك قاعدة العملاء',
                          'count': clients.length.toString(),
                          'icon': Icons.people,
                          'color': Colors.purple,
                        },
                        {
                          'title': 'تقارير الناقلين',
                          'description': 'كفاءة وجودة خدمات النقل',
                          'count': carriers.length.toString(),
                          'icon': Icons.local_shipping,
                          'color': Colors.orange,
                        },
                      ];
                      final category = categories[index];
                      VoidCallback? onTap;
                      if (index == 0) {
                        onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _OrdersReportsPage(),
                            ),
                          );
                        };
                      } else if (index == 1) {
                        onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _SuppliersReportsPage(),
                            ),
                          );
                        };
                      } else if (index == 2) {
                        onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _ClientsReportsPage(),
                            ),
                          );
                        };
                      } else if (index == 3) {
                        onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _CarriersReportsPage(),
                            ),
                          );
                        };
                      }
                      return _ReportCategoryCard(
                        title: category['title'] as String,
                        description: category['description'] as String,
                        count: category['count'] as String,
                        icon: category['icon'] as IconData,
                        color: category['color'] as Color,
                        onPressed: onTap,
                      );
                    }, childCount: 4),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التقارير الحديثة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                // Recent Reports List
                orders.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد تقارير',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final order = orders[index];
                            return _RecentReportCard(order: order);
                          }, childCount: orders.take(5).length),
                        ),
                      ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _ReportCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ReportCategoryCard({
    required this.title,
    required this.description,
    required this.count,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count تقرير',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onPressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'عرض التقارير',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _RecentReportCard({required this.order});

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'مكتمل';
      case 'in_progress':
      case 'processing':
      case 'in_delivery':
        return 'قيد التنفيذ';
      case 'pending':
      case 'initial':
        return 'قيد المراجعة';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'جديد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'processing':
      case 'in_delivery':
        return Colors.orange;
      case 'pending':
      case 'initial':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString();
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          isScrollControlled: true,
          builder: (_) {
            final orderId = order['order_number'] ?? order['id'] ?? '-';
            final buyer = order['Buyer']?['name'] ?? order['buyer_name'] ?? '-';
            final supplier =
                order['Supplier']?['name'] ?? order['supplier_name'] ?? '-';
            final total = order['total_price']?.toString() ?? '-';
            final date = order['order_date'] ?? order['createdAt'] ?? '-';
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, controller) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: controller,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: statusColor.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(Icons.description, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'طلب #$orderId',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _chip(statusText, statusColor),
                                    if (buyer != '-')
                                      _chip('المشتري: $buyer', Colors.blue),
                                    if (supplier != '-')
                                      _chip('المورد: $supplier', Colors.orange),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _infoTile('الإجمالي', total),
                          _infoTile('التاريخ', date.toString()),
                          _infoTile('الحالة', statusText),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      // عرض تفاصيل مختارة بعناوين عربية واضحة
                      ...(() {
                        final List<MapEntry<String, String>> details = [];
                        void add(String label, dynamic value) {
                          final v = (value == null) ? '' : value.toString();
                          if (v.trim().isEmpty || v == '-' || v == 'null')
                            return;
                          details.add(MapEntry(label, v));
                        }

                        add('رقم الطلب', order['order_number'] ?? order['id']);
                        add('الحالة', statusText);
                        add(
                          'المشتري',
                          order['Buyer']?['name'] ?? order['buyer_name'],
                        );
                        add(
                          'المورد',
                          order['Supplier']?['name'] ?? order['supplier_name'],
                        );
                        add('الإجمالي', order['total_price']);
                        add(
                          'التاريخ',
                          order['order_date'] ?? order['createdAt'],
                        );
                        add(
                          'طريقة الدفع',
                          order['payment_method'] ?? order['paymentMethod'],
                        );
                        add('المدينة', order['city']);
                        add('المنطقة', order['region']);
                        add('العنوان', order['address']);
                        add('ملاحظات', order['notes'] ?? order['note']);
                        add(
                          'عدد العناصر',
                          order['items'] is List
                              ? (order['items'] as List).length
                              : order['items_count'],
                        );

                        return details.map(
                          (e) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description, color: statusColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طلب #${order['order_number'] ?? order['id'] ?? '-'} - ${order['Buyer']?['name'] ?? 'غير محدد'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order['createdAt'] != null
                            ? DateTime.parse(
                                order['createdAt'],
                              ).toString().split(' ')[0]
                            : 'غير محدد',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ProgressCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.circle, color: color, size: 8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }
}

class _SuppliersReportsPage extends ConsumerWidget {
  const _SuppliersReportsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(adminSuppliersListProvider);
    final ordersAsync = ref.watch(adminOrdersListProvider);
    final dio = ApiClient.build();

    Future<List<Map<String, dynamic>>> fetchProducts() async {
      try {
        final res = await dio.get('/products');
        final data = res.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        if (data is Map && data['products'] is List) {
          return (data['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data is Map && data['data']?['products'] is List) {
          return (data['data']['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      } catch (_) {}
      return [];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تقارير الموردين')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: suppliersAsync.when(
          data: (suppliers) {
            final total = suppliers.length;
            final active = suppliers
                .where((s) => s['active'] == 'active')
                .length;
            final inactive = total - active;

            return ordersAsync.when(
              data: (orders) {
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchProducts(),
                  builder: (context, snapshot) {
                    final products = snapshot.data ?? const [];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ProgressCard(
                                  icon: Icons.store,
                                  title: 'إجمالي الموردين',
                                  value: total.toString(),
                                  progress: 1.0,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ProgressCard(
                                  icon: Icons.verified,
                                  title: 'النشطون',
                                  value: active.toString(),
                                  progress: total > 0 ? active / total : 0,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ProgressCard(
                                  icon: Icons.pause_circle_outline,
                                  title: 'غير نشط',
                                  value: inactive.toString(),
                                  progress: total > 0 ? inactive / total : 0,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ],
                          ),

                          const SizedBox(height: 24),
                          _TopRegions(suppliers: suppliers),

                          const SizedBox(height: 24),
                          Text(
                            'قائمة الموردين',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: suppliers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (ctx, i) {
                              final s = suppliers[i];
                              final supplierId = s['id']?.toString();
                              final supplierOrders = orders
                                  .where(
                                    (o) =>
                                        (o['supplier_id']?.toString() ??
                                            o['SupplierId']?.toString()) ==
                                        supplierId,
                                  )
                                  .toList();
                              final supplierProducts = products
                                  .where(
                                    (p) =>
                                        (p['supplier_id']?.toString() ??
                                            p['SupplierId']?.toString()) ==
                                        supplierId,
                                  )
                                  .toList();
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        (s['active'] == 'active'
                                                ? Colors.green
                                                : Colors.grey)
                                            .withOpacity(0.15),
                                    child: Icon(
                                      s['active'] == 'active'
                                          ? Icons.check_circle
                                          : Icons.remove_circle_outline,
                                      color: s['active'] == 'active'
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  title: Text('${s['name'] ?? '-'}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المنطقة: ${s['Region']?['name'] ?? s['region']?['name'] ?? '-'}',
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'منتجات: ${supplierProducts.length}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'طلبات: ${supplierOrders.length}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.purple,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_left),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (_) {
                                        return DraggableScrollableSheet(
                                          expand: false,
                                          initialChildSize: 0.7,
                                          minChildSize: 0.4,
                                          maxChildSize: 0.95,
                                          builder: (context, controller) {
                                            return Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'تفاصيل المورد: ${s['name'] ?? '-'}',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'المنتجات (${supplierProducts.length})',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      controller: controller,
                                                      itemCount:
                                                          supplierProducts
                                                              .length,
                                                      itemBuilder: (ctx, idx) {
                                                        final p =
                                                            supplierProducts[idx];
                                                        return ListTile(
                                                          leading: const Icon(
                                                            Icons
                                                                .inventory_2_outlined,
                                                          ),
                                                          title: Text(
                                                            '${p['name'] ?? '-'}',
                                                          ),
                                                          subtitle: Text(
                                                            'السعر: ${p['price'] ?? p['unit_price'] ?? '-'}',
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'الطلبات (${supplierOrders.length})',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      controller: controller,
                                                      itemCount:
                                                          supplierOrders.length,
                                                      itemBuilder: (ctx, idx) {
                                                        final o =
                                                            supplierOrders[idx];
                                                        return ListTile(
                                                          leading: const Icon(
                                                            Icons.receipt_long,
                                                          ),
                                                          title: Text(
                                                            'طلب #${o['order_number'] ?? o['id'] ?? '-'}',
                                                          ),
                                                          subtitle: Text(
                                                            'الحالة: ${o['status'] ?? '-'} • الإجمالي: ${o['total_price'] ?? '-'}',
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _OrdersReportsPage extends ConsumerWidget {
  const _OrdersReportsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersListProvider);
    final dio = ApiClient.build();

    Future<List<Map<String, dynamic>>> fetchProducts() async {
      try {
        final res = await dio.get('/products');
        final data = res.data;
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data['products'] is List) {
          return (data['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data is Map && data['data']?['products'] is List) {
          return (data['data']['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      } catch (_) {}
      return [];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تقارير الطلبات')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ordersAsync.when(
          data: (orders) {
            final completed = orders
                .where((o) => o['status'] == 'completed')
                .length;
            final processing = orders
                .where(
                  (o) => [
                    'in_delivery',
                    'in_progress',
                    'processing',
                  ].contains(o['status']),
                )
                .length;
            final pending = orders
                .where((o) => ['pending', 'initial'].contains(o['status']))
                .length;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                final products = snapshot.data ?? const [];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ProgressCard(
                            icon: Icons.assignment,
                            title: 'إجمالي الطلبات',
                            value: orders.length.toString(),
                            progress: 1,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProgressCard(
                            icon: Icons.check_circle,
                            title: 'مكتملة',
                            value: completed.toString(),
                            progress: orders.isNotEmpty
                                ? completed / orders.length
                                : 0,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ProgressCard(
                            icon: Icons.schedule,
                            title: 'قيد التنفيذ',
                            value: processing.toString(),
                            progress: orders.isNotEmpty
                                ? processing / orders.length
                                : 0,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProgressCard(
                            icon: Icons.access_time,
                            title: 'قيد المراجعة',
                            value: pending.toString(),
                            progress: orders.isNotEmpty
                                ? pending / orders.length
                                : 0,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'الطلبات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...orders.map(
                      (o) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            'طلب #${o['order_number'] ?? o['id'] ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'الحالة: ${o['status'] ?? '-'} • الإجمالي: ${o['total_price'] ?? '-'}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'المنتجات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (products.isEmpty)
                      const Text('لا توجد منتجات')
                    else
                      ...products.map(
                        (p) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(
                              '${p['name'] ?? '-'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'السعر: ${p['price'] ?? p['unit_price'] ?? '-'} • الحالة: ${(p['status'] ?? 'غير محدد')}',
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _ClientsReportsPage extends ConsumerWidget {
  const _ClientsReportsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(adminClientsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تقارير العملاء')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: clientsAsync.when(
          data: (clients) {
            final active = clients.where((c) => c['active'] == 'active').length;
            final inactive = clients.length - active;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.people,
                        title: 'إجمالي العملاء',
                        value: clients.length.toString(),
                        progress: 1,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.verified_user,
                        title: 'نشط',
                        value: active.toString(),
                        progress: clients.isNotEmpty
                            ? active / clients.length
                            : 0,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.pause_circle_outline,
                        title: 'غير نشط',
                        value: inactive.toString(),
                        progress: clients.isNotEmpty
                            ? inactive / clients.length
                            : 0,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 16),
                ...clients.map(
                  (c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: c['active'] == 'active'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text('${c['name'] ?? '-'}'),
                      subtitle: Text('الجوال: ${c['jwal'] ?? '-'}'),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _CarriersReportsPage extends ConsumerWidget {
  const _CarriersReportsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carriersAsync = ref.watch(adminCarriersListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تقارير الناقلين')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: carriersAsync.when(
          data: (carriers) {
            final active = carriers
                .where((c) => c['active'] == 'active')
                .length;
            final inactive = carriers.length - active;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.local_shipping,
                        title: 'إجمالي الناقلين',
                        value: carriers.length.toString(),
                        progress: 1,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.verified,
                        title: 'نشط',
                        value: active.toString(),
                        progress: carriers.isNotEmpty
                            ? active / carriers.length
                            : 0,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.pause_circle_outline,
                        title: 'غير نشط',
                        value: inactive.toString(),
                        progress: carriers.isNotEmpty
                            ? inactive / carriers.length
                            : 0,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 16),
                ...carriers.map(
                  (c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.local_shipping,
                        color: c['active'] == 'active'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text('${c['name'] ?? '-'}'),
                      subtitle: Text('الجوال: ${c['jwal'] ?? '-'}'),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _ModernNavDestination extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;

  const _ModernNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationDestination(
      icon: Tooltip(
        message: label,
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Icon(
                isSelected ? selectedIcon : icon,
                size: isSelected ? 26 : 22,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
      selectedIcon: Tooltip(
        message: label,
        child: AnimatedScale(
          scale: 1.3,
          duration: const Duration(milliseconds: 100),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              Icon(selectedIcon, size: 30, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
      label: label,
    );
  }
}
