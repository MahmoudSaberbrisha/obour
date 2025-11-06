import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buyer_providers.dart';
import 'package:dio/dio.dart';
import '../../../core/storage/secure_storage.dart';

class BuyerCreateOrderPage extends ConsumerStatefulWidget {
  const BuyerCreateOrderPage({super.key});

  @override
  ConsumerState<BuyerCreateOrderPage> createState() =>
      _BuyerCreateOrderPageState();
}

class _BuyerCreateOrderPageState extends ConsumerState<BuyerCreateOrderPage> {
  int? supplierId;
  int? carrierId;
  int? productId;
  int quantity = 1;
  int? buyerId;
  String status = 'initial';
  final pickupCtrl = TextEditingController();
  final deliveryCtrl = TextEditingController();
  final taxCtrl = TextEditingController(text: '0');
  DateTime? orderDate;
  final priceCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  @override
  void dispose() {
    priceCtrl.dispose();
    notesCtrl.dispose();
    pickupCtrl.dispose();
    deliveryCtrl.dispose();
    taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(buyerClientsProvider);
    final suppliersAsync = ref.watch(buyerSuppliersProvider);
    final carriersAsync = ref.watch(buyerCarriersProvider);
    final productsAsync = ref.watch(buyerProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء طلب')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // المنتج
            Text('المنتج', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            productsAsync.when(
              data: (products) {
                final filtered = supplierId == null
                    ? products
                    : products.where((p) {
                        final sid = p['supplier_id'] ?? p['supplierId'];
                        return sid != null &&
                            (sid as num).toInt() == supplierId;
                      }).toList();
                return DropdownButtonFormField<int>(
                  value: productId,
                  items: filtered.map((p) {
                    final price = (p['price'] ?? p['unit_price'] ?? 0)
                        .toString();
                    return DropdownMenuItem(
                      value: (p['id'] as num).toInt(),
                      child: Text('${p['name'] ?? 'منتج'} - $price'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      productId = v;
                      final p = filtered.firstWhere(
                        (e) => (e['id'] as num).toInt() == v,
                        orElse: () => {},
                      );
                      final up = (p is Map)
                          ? (p['price'] ?? p['unit_price'] ?? 0)
                          : 0;
                      final parsed = (up is num)
                          ? up
                          : (num.tryParse(up.toString()) ?? 0);
                      priceCtrl.text = (parsed * quantity).toString();
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطأ: $e'),
            ),
            const SizedBox(height: 12),
            Text('الكمية', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    quantity = quantity > 1 ? quantity - 1 : 1;
                    final current = num.tryParse(priceCtrl.text) ?? 0;
                    if (current > 0) {
                      final unit = current / (quantity + 1);
                      priceCtrl.text = (unit * quantity).toString();
                    }
                  }),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$quantity'),
                IconButton(
                  onPressed: () => setState(() {
                    quantity += 1;
                    final current = num.tryParse(priceCtrl.text) ?? 0;
                    if (current > 0 && quantity > 1) {
                      final unit = current / (quantity - 1);
                      priceCtrl.text = (unit * quantity).toString();
                    }
                  }),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // المشتري (جلب مثل المورد/الناقل + اختيار تلقائي للمستخدم الحالي)
            Text('المشتري', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            clientsAsync.when(
              data: (clients) {
                return FutureBuilder<String?>(
                  future: SecureStorage().readUserName(),
                  builder: (context, snap) {
                    final currentName = snap.data ?? '';
                    if (buyerId == null && clients.isNotEmpty) {
                      final match = clients.firstWhere(
                        (c) => (c['name']?.toString() ?? '') == currentName,
                        orElse: () => clients.first,
                      );
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(
                            () => buyerId = (match['id'] as num).toInt(),
                          );
                        }
                      });
                    }
                    return DropdownButtonFormField<int>(
                      value: buyerId,
                      items: clients.map((c) {
                        return DropdownMenuItem(
                          value: (c['id'] as num).toInt(),
                          child: Text(c['name']?.toString() ?? '—'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => buyerId = v),
                    );
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطأ: $e'),
            ),
            const SizedBox(height: 12),
            // المورد
            Text('المورد', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            suppliersAsync.when(
              data: (suppliers) => DropdownButtonFormField<int>(
                value: supplierId,
                items: suppliers.map((s) {
                  return DropdownMenuItem(
                    value: (s['id'] as num).toInt(),
                    child: Text(s['name']?.toString() ?? '—'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => supplierId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطأ: $e'),
            ),
            const SizedBox(height: 12),
            Text('الناقل', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            carriersAsync.when(
              data: (carriers) => DropdownButtonFormField<int>(
                value: carrierId,
                items: carriers.map((c) {
                  return DropdownMenuItem(
                    value: (c['id'] as num).toInt(),
                    child: Text(c['name']?.toString() ?? '—'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => carrierId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطأ: $e'),
            ),
            const SizedBox(height: 12),
            Text('حالة الطلب', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'initial', child: Text('قيد المراجعة')),
                DropdownMenuItem(
                  value: 'waiting_carrier',
                  child: Text('بانتظار الناقل'),
                ),
                DropdownMenuItem(
                  value: 'in_delivery',
                  child: Text('قيد التوصيل'),
                ),
                DropdownMenuItem(value: 'completed', child: Text('مكتمل')),
                DropdownMenuItem(value: 'cancelled', child: Text('ملغي')),
              ],
              onChanged: (v) => setState(() => status = v ?? 'initial'),
            ),
            const SizedBox(height: 12),
            Text(
              'السعر الإجمالي',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
            ),
            const SizedBox(height: 12),
            Text('مكان التحميل', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: pickupCtrl,
              decoration: const InputDecoration(hintText: 'المدينة، العنوان'),
            ),
            const SizedBox(height: 12),
            Text('مكان التوصيل', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: deliveryCtrl,
              decoration: const InputDecoration(hintText: 'المدينة، العنوان'),
            ),
            const SizedBox(height: 12),
            Text('الضريبة (%)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: taxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
            ),
            const SizedBox(height: 12),
            Text('تاريخ الطلب', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    orderDate == null
                        ? '—'
                        : '${orderDate!.year}-${orderDate!.month.toString().padLeft(2, '0')}-${orderDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => orderDate = picked);
                  },
                  child: const Text('اختيار التاريخ'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('ملاحظات', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: notesCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'ملاحظات (اختياري)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (supplierId == null || buyerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('اختر المشتري والمورد')),
                    );
                    return;
                  }
                  if ((num.tryParse(priceCtrl.text) ?? 0) <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('أدخل السعر الإجمالي بشكل صحيح (> 0)'),
                      ),
                    );
                    return;
                  }
                  final String dateOnly = (orderDate ?? DateTime.now())
                      .toLocal()
                      .toString()
                      .split(' ')
                      .first; // yyyy-MM-dd
                  final payload = {
                    'buyer_id': buyerId,
                    'supplier_id': supplierId,
                    if (carrierId != null) 'carrier_id': carrierId,
                    'status': status,
                    'total_price': num.tryParse(priceCtrl.text) ?? 0,
                    'order_date': dateOnly,
                    'notes': notesCtrl.text.trim(),
                    if (taxCtrl.text.trim().isNotEmpty)
                      'tax': num.tryParse(taxCtrl.text.trim()) ?? 0,
                    if (pickupCtrl.text.trim().isNotEmpty)
                      'pickup_location': pickupCtrl.text.trim(),
                    if (deliveryCtrl.text.trim().isNotEmpty)
                      'delivery_location': deliveryCtrl.text.trim(),
                    if (productId != null) 'product_id': productId,
                  };
                  try {
                    final created = await ref.read(
                      createOrderProvider(payload).future,
                    );
                    if (!mounted) return;
                    if (created == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'فشل إنشاء الطلب (تحقق من الحقول والقيم)',
                          ),
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إنشاء الطلب')),
                    );
                    Navigator.of(context).pop(true);
                  } on DioException catch (e) {
                    if (!mounted) return;
                    final data = e.response?.data;
                    String message = 'فشل إنشاء الطلب';
                    if (data is Map && data['message'] != null) {
                      message = data['message'].toString();
                    } else if (data != null) {
                      message = data.toString();
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('إضافة الطلب'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
