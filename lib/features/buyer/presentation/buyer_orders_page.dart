import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buyer_providers.dart';
import 'buyer_create_order_page.dart';

class BuyerOrdersPage extends ConsumerWidget {
  const BuyerOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider(50));
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ordersAsync.when(
          data: (orders) => ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final o = orders[i];
              final status = (o['status'] ?? '').toString();
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('#${o['order_number'] ?? o['id'] ?? '-'}'),
                  ),
                  title: Text('الحالة: ${_statusArabic(status)}'),
                  subtitle: Text(
                    'التاريخ: ${(o['order_date'] ?? o['createdAt'] ?? '').toString()}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'cancel') {
                        await ref.read(
                          cancelOrderProvider(
                            (o['id'] ?? o['order_number']).toString(),
                          ).future,
                        );
                        ref.invalidate(buyerOrdersProvider);
                      }
                    },
                    itemBuilder: (c) => [
                      if (!['completed', 'cancelled'].contains(status))
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('إلغاء'),
                        ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BuyerOrderDetailsPage(order: o),
                    ),
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const BuyerCreateOrderPage()),
          );
          if (created == true) {
            ref.invalidate(buyerOrdersProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
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
}

class BuyerOrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const BuyerOrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلب #${order['order_number'] ?? order['id'] ?? '-'}'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _row('الحالة', (order['status'] ?? '-').toString()),
            _row('المبلغ', (order['total_price'] ?? '-').toString()),
            _row(
              'التاريخ',
              (order['order_date'] ?? order['createdAt'] ?? '-').toString(),
            ),
            _row('ملاحظات', (order['notes'] ?? '-').toString()),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text(v),
      ],
    ),
  );
}
