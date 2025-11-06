import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/widgets/details_page.dart';
import '../../../core/widgets/modern_card.dart';
import 'buyer_providers.dart';

final buyerUserNameProvider = FutureProvider<String?>((ref) async {
  final storage = SecureStorage();
  return await storage.readUserName();
});

class BuyerHomePage extends ConsumerWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final userNameAsync = ref.watch(buyerUserNameProvider);
    final ordersAsync = ref.watch(buyerOrdersProvider(20));

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
        ordersAsync.when(
          data: (orders) {
            final list = List<Map<String, dynamic>>.from(orders);
            final completed = list
                .where((o) => (o['status'] ?? '') == 'completed')
                .length;
            final inProgress = list
                .where(
                  (o) => [
                    'in_progress',
                    'processing',
                    'in_delivery',
                  ].contains(o['status']),
                )
                .length;
            return Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'إجمالي الطلبات',
                    value: list.length.toString(),
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _kpiCard(
                    context,
                    icon: Icons.check_circle_outline,
                    title: 'مكتملة',
                    value: completed.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kpiCard(
                    context,
                    icon: Icons.timelapse,
                    title: 'قيد التنفيذ',
                    value: inProgress.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
          loading: () => Row(
            children: [
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: '…',
                  value: '—',
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.check_circle_outline,
                  title: '…',
                  value: '—',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.timelapse,
                  title: '…',
                  value: '—',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          error: (_, __) => Row(
            children: [
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.error_outline,
                  title: 'خطأ',
                  value: '—',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('الأقسام البارزة', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 108,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chipCard(context, 'خضار وفواكه', Icons.eco_outlined, colors),
              _chipCard(context, 'مخبوزات', Icons.cookie_outlined, colors),
              _chipCard(context, 'مشروبات', Icons.local_drink_outlined, colors),
              _chipCard(
                context,
                'ألبان',
                Icons.local_grocery_store_outlined,
                colors,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('أحدث الطلبات', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ordersAsync.when(
          data: (orders) {
            final recent = List<Map<String, dynamic>>.from(
              orders,
            ).take(5).toList();
            if (recent.isEmpty) {
              return const Card(child: ListTile(title: Text('لا توجد طلبات')));
            }
            return Column(
              children: [
                for (final o in recent)
                  _orderTile(
                    context,
                    '#${o['order_number'] ?? o['id'] ?? '-'}',
                    _statusArabic(o['status']?.toString()),
                    (o['order_date'] ?? o['createdAt'] ?? '').toString(),
                    colors,
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Card(child: ListTile(title: Text('خطأ: $e'))),
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
  }) {
    return AnimatedStatCard(
      icon: icon,
      title: title,
      value: value,
      color: color,
      trend: '↑ 12%',
    );
  }

  Widget _kpiCardOld(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final gradient = LinearGradient(
      colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
    );
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '↑ 12%',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            alignment: AlignmentDirectional.centerStart,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(height: 28, child: _sparkline(color)),
        ],
      ),
    );
  }

  Widget _chipCard(
    BuildContext context,
    String title,
    IconData icon,
    ColorScheme colors,
  ) {
    return SizedBox(
      width: 160,
      child: Card(
        color: colors.primary.withOpacity(0.06),
        child: InkWell(
          onTap: () => _openDetails(
            context,
            title,
            'تفاصيل حول "$title" للمشتري. يمكنك استعراض محتوى هذا القسم لاحقاً ببيانات حقيقية.',
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderTile(
    BuildContext context,
    String id,
    String status,
    String time,
    ColorScheme colors,
  ) {
    Color sColor = status == 'مكتمل'
        ? Colors.green
        : status == 'ملغي'
        ? Colors.red
        : colors.primary;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sColor.withOpacity(0.12),
          child: Icon(Icons.receipt_long_outlined, color: sColor),
        ),
        title: Text('طلب $id'),
        subtitle: Text(status),
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
          'تفاصيل الطلب $id',
          'الحالة: $status\nالوقت: $time',
        ),
      ),
    );
  }

  String _statusArabic(String? status) {
    switch ((status ?? '').toLowerCase()) {
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

  Widget _sparkline(Color color) {
    final data = const [4.0, 4.4, 3.8, 5.2, 6.0, 5.6, 6.4, 7.2];
    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.10),
            ),
            spots: [
              for (int i = 0; i < data.length; i++)
                FlSpot(i.toDouble(), data[i]),
            ],
          ),
        ],
        minX: 0,
        maxX: 7,
      ),
    );
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
