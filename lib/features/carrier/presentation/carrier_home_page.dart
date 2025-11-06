import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/widgets/details_page.dart';
import '../../../core/widgets/modern_card.dart';
import 'carrier_providers.dart';

final carrierUserNameProvider = FutureProvider<String?>((ref) async {
  final storage = SecureStorage();
  return await storage.readUserName();
});

class CarrierHomePage extends ConsumerWidget {
  const CarrierHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final userNameAsync = ref.watch(carrierUserNameProvider);
    final statsAsync = ref.watch(carrierStatsProvider);
    final ordersAsync = ref.watch(carrierOrdersProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        userNameAsync.when(
          data: (name) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              name != null && name.isNotEmpty ? 'مرحباً بك $name' : 'مرحباً بك',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        statsAsync.when(
          data: (stats) => Row(
            children: [
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: 'شحنات نشطة',
                  value: '${stats['activeOrders'] ?? 0}',
                  color: colors.primary,
                  showTrend: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'شحنات مكتملة',
                  value: '${stats['completedOrders'] ?? 0}',
                  color: colors.primary,
                  showTrend: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.today_outlined,
                  title: 'شحنات اليوم',
                  value: '${stats['todayOrders'] ?? 0}',
                  color: colors.primary,
                  showTrend: false,
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(),
        ),
        const SizedBox(height: 16),
        Text('الشحنات النشطة', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا توجد شحنات',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final activeOrders = orders
                .where((order) {
                  final status = order['status']?.toString().toLowerCase();
                  return status == 'shipped' ||
                      status == 'in_transit' ||
                      status == 'pickup' ||
                      status == 'in_delivery' ||
                      status == 'waiting_carrier';
                })
                .take(5)
                .toList();

            if (activeOrders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا توجد شحنات نشطة حالياً',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: activeOrders.map((order) {
                final orderId = order['order_number'] ?? order['id'] ?? '-';
                final status = _getStatusText(order['status']);
                final date = order['createdAt'] ?? order['order_date'];
                final timeText = date != null
                    ? _formatDate(date.toString())
                    : 'غير محدد';
                return _orderTile(
                  context,
                  colors,
                  orderId.toString(),
                  status,
                  timeText,
                  order,
                );
              }).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'خطأ في تحميل الشحنات',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'سجل الشحنات الأخيرة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا يوجد سجل شحنات',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final recentOrders = orders
                .where((order) {
                  final status = order['status']?.toString().toLowerCase();
                  return status == 'delivered' || status == 'completed';
                })
                .take(5)
                .toList();

            if (recentOrders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا توجد شحنات مكتملة بعد',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: recentOrders.map((order) {
                final orderId = order['order_number'] ?? order['id'] ?? '-';
                final status = _getStatusText(order['status']);
                final date = order['createdAt'] ?? order['order_date'];
                final timeText = date != null
                    ? _formatDate(date.toString())
                    : 'غير محدد';
                return _historyTile(
                  context,
                  colors,
                  orderId.toString(),
                  status,
                  timeText,
                  order,
                );
              }).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'خطأ في تحميل السجل',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool showTrend = true,
  }) {
    return AnimatedStatCard(
      icon: icon,
      title: title,
      value: value,
      color: color,
      trend: showTrend ? '↑ 6%' : null,
    );
  }

  Widget _orderTile(
    BuildContext context,
    ColorScheme colors,
    String id,
    String status,
    String time,
    Map<String, dynamic> order,
  ) {
    Color sColor = status == 'مكتمل' || status == 'تم التسليم'
        ? Colors.green
        : status == 'ملغي'
        ? Colors.red
        : colors.primary;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sColor.withOpacity(0.12),
          child: Icon(Icons.local_shipping_outlined, color: sColor),
        ),
        title: Text('طلب #$id'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status),
            if (order['Buyer'] != null && order['Buyer'] is Map)
              Text(
                'العميل: ${order['Buyer']['name'] ?? 'غير محدد'}',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time, style: Theme.of(context).textTheme.labelSmall),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _openDetails(
          context,
          'تفاصيل الشحنة #$id',
          'الحالة: $status\nالوقت: $time',
        ),
      ),
    );
  }

  Widget _historyTile(
    BuildContext context,
    ColorScheme colors,
    String id,
    String status,
    String time,
    Map<String, dynamic> order,
  ) {
    Color sColor = status == 'مكتمل' || status == 'تم التسليم'
        ? Colors.green
        : colors.primary;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sColor.withOpacity(0.12),
          child: Icon(Icons.history_outlined, color: sColor),
        ),
        title: Text('طلب #$id'),
        subtitle: Text(status),
        trailing: Text(time, style: Theme.of(context).textTheme.labelSmall),
        onTap: () => _openDetails(
          context,
          'سجل الشحنة #$id',
          'الحالة: $status\nالوقت: $time',
        ),
      ),
    );
  }

  String _getStatusText(dynamic status) {
    if (status == null) return 'غير محدد';
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
      case 'initial':
      case 'new':
      case 'جديد':
        return 'جديد';
      case 'waiting_carrier':
        return 'في انتظار الناقل';
      case 'pickup':
      case 'ready_for_pickup':
        return 'جاهز للاستلام';
      case 'in_transit':
      case 'shipped':
      case 'in_delivery':
      case 'قيد النقل':
        return 'قيد النقل';
      case 'delivered':
      case 'completed':
      case 'مكتمل':
        return 'تم التسليم';
      case 'cancelled':
      case 'ملغي':
        return 'ملغي';
      default:
        return status.toString();
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        final hour = date.hour;
        final minute = date.minute.toString().padLeft(2, '0');
        final period = hour < 12 ? 'ص' : 'م';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return 'اليوم $displayHour:$minute $period';
      } else if (difference.inDays == 1) {
        final hour = date.hour;
        final minute = date.minute.toString().padLeft(2, '0');
        final period = hour < 12 ? 'ص' : 'م';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return 'أمس $displayHour:$minute $period';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _openDetails(
    BuildContext context,
    String title,
    String subtitle, [
    List<Widget> children = const [],
  ]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DetailsPage(title: title, subtitle: subtitle, children: children),
      ),
    );
  }
}
