import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/env.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/widgets/details_page.dart';
import '../../../core/widgets/modern_card.dart';
import 'supplier_providers.dart';

final supplierUserNameProvider = FutureProvider<String?>((ref) async {
  final storage = SecureStorage();
  return await storage.readUserName();
});

class SupplierHomePage extends ConsumerWidget {
  const SupplierHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final userNameAsync = ref.watch(supplierUserNameProvider);
    final statsAsync = ref.watch(supplierStatsProvider);
    final ordersAsync = ref.watch(supplierOrdersProvider);
    final productsAsync = ref.watch(supplierProductsProvider);

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
                  icon: Icons.attach_money_rounded,
                  title: 'إيراد اليوم',
                  value:
                      '${_formatNumber(_parseDouble(stats['todayRevenue']))} ر.س',
                  color: colors.primary,
                  showTrend: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'طلبات جديدة',
                  value: '${stats['newOrdersCount'] ?? 0}',
                  color: colors.primary,
                  showTrend: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kpiCard(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: 'منتجات منخفضة',
                  value: '${stats['lowStockCount'] ?? 0}',
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
        Text('إدارة سريعة', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _quickAction(
              context,
              colors,
              Icons.add_box_outlined,
              'إضافة منتج',
              onTap: () => _showAddProductSheet(context, ref),
            ),
            _quickAction(
              context,
              colors,
              Icons.edit_note_outlined,
              'تعديل الأسعار',
              onTap: () => _showBulkPriceUpdateSheet(context, ref),
            ),
            _quickAction(
              context,
              colors,
              Icons.inventory_outlined,
              'تحديث المخزون',
              onTap: () => _showBulkStockUpdateSheet(context, ref),
            ),
            _quickAction(
              context,
              colors,
              Icons.local_offer_outlined,
              'إنشاء عرض',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('أحدث الطلبات', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا توجد طلبات',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: orders.take(3).map((order) {
                final orderId = order['order_number'] ?? order['id'] ?? '-';
                final status = _getStatusText(order['status']);
                final date = order['createdAt'] ?? order['order_date'];
                final timeText = date != null
                    ? _formatDate(date.toString())
                    : 'غير محدد';
                return _orderTile(
                  context,
                  orderId.toString(),
                  status,
                  timeText,
                  colors,
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
              'خطأ في تحميل الطلبات',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'أفضل المنتجات أداءً',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا توجد منتجات',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topProducts(context, colors, products),
                const SizedBox(height: 16),
                Text(
                  'جميع المنتجات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  itemCount: products.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final name = p['name']?.toString() ?? '-';
                    final priceDyn = p['price'];
                    final price = priceDyn is num
                        ? priceDyn.toDouble()
                        : double.tryParse(priceDyn?.toString() ?? '0') ?? 0.0;
                    final stockDyn =
                        p['stock_quantity'] ?? p['stock'] ?? p['quantity'];
                    final stock = stockDyn is num
                        ? stockDyn.toInt()
                        : int.tryParse(stockDyn?.toString() ?? '0') ?? 0;
                    final status = p['status']?.toString() ?? 'active';
                    final imageUrl = _resolveImageUrl(
                      p['image_url']?.toString(),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ModernCard(
                        child: Row(
                          children: [
                            if (imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: colors.surfaceVariant.withOpacity(
                                        0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: colors.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: colors.primary,
                                  size: 24,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sell_outlined,
                                        size: 14,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${_formatNumber(price)} ر.س',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.storage_rounded,
                                        size: 14,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'المخزون: $stock',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: colors.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  _statusTextAr(status),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.primary,
                                        fontSize: 10,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'خطأ في تحميل المنتجات',
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
      trend: showTrend ? '↑ 9%' : null,
    );
  }

  String _statusTextAr(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      case 'out_of_stock':
        return 'نفد المخزون';
      case 'discontinued':
        return 'متوقف';
      default:
        return status;
    }
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = Env.apiBaseUrl;
    final uri = Uri.parse(base);
    final origin =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    if (url.startsWith('/')) return '$origin$url';
    return '$origin/$url';
  }

  Widget _quickAction(
    BuildContext context,
    ColorScheme colors,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 170,
      child: Card(
        color: colors.primary.withOpacity(0.06),
        child: InkWell(
          onTap:
              onTap ??
              () => _openDetails(
                context,
                title,
                'تفاصيل عن "$title" للمورد. سيتم استبدال هذه البيانات لاحقاً بمحتوى فعلي.',
              ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(title)),
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
    ColorScheme colors, [
    Map<String, dynamic>? orderData,
  ]) {
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
        title: Text('طلب #$id'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status),
            if (orderData?['total_price'] != null)
              Text(
                '${_formatNumber(_parseDouble(orderData!['total_price']))} ر.س',
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
          'تفاصيل الطلب #$id',
          'الحالة: $status\nالوقت: $time${orderData?['total_price'] != null ? '\nالإجمالي: ${_formatNumber(_parseDouble(orderData!['total_price']))} ر.س' : ''}',
        ),
      ),
    );
  }

  String _getStatusText(dynamic status) {
    if (status == null) return 'غير محدد';
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'completed':
      case 'مكتمل':
        return 'مكتمل';
      case 'pending':
      case 'initial':
      case 'new':
      case 'جديد':
        return 'جديد';
      case 'processing':
      case 'in_progress':
      case 'قيد التنفيذ':
        return 'قيد التنفيذ';
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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String _formatNumber(double number) {
    if (number == 0) return '0';
    final parts = number.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = parts.length - 1; i >= 0; i--) {
      buffer.write(parts[i]);
      if ((parts.length - 1 - i) % 3 == 2 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  Widget _topProducts(
    BuildContext context,
    ColorScheme colors,
    List<Map<String, dynamic>> products,
  ) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'لا توجد منتجات',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final topProducts = products.take(3).toList();
    final maxSales = topProducts.fold<double>(0.0, (max, product) {
      final sales =
          double.tryParse(product['sold_quantity']?.toString() ?? '0') ?? 0.0;
      return sales > max ? sales : max;
    });

    return Column(
      children: [
        if (topProducts.isNotEmpty)
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < topProducts.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY:
                              (double.tryParse(
                                    topProducts[i]['sold_quantity']
                                            ?.toString() ??
                                        '0',
                                  ) ??
                                  0.0) /
                              (maxSales > 0 ? maxSales : 1) *
                              14,
                          color: colors.primary,
                        ),
                      ],
                    ),
                ],
                maxY: 14,
              ),
            ),
          ),
        const SizedBox(height: 8),
        ...topProducts.map((product) {
          final name = product['name']?.toString() ?? 'منتج غير محدد';
          final sales = product['sold_quantity'] ?? product['quantity'] ?? 0;
          final salesText = '$sales مبيع';
          return _productRow(
            context,
            colors,
            name,
            salesText,
            Icons.inventory_2_outlined,
          );
        }),
      ],
    );
  }

  Widget _productRow(
    BuildContext context,
    ColorScheme colors,
    String name,
    String meta,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.12),
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(name),
        subtitle: Text(meta),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openDetails(context, 'تفاصيل المنتج', '$name\n$meta'),
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

  Future<void> _showAddProductSheet(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final minStockController = TextEditingController(text: '0');
    final skuController = TextEditingController();
    final descController = TextEditingController();
    String status = 'active';
    int? selectedCategoryId;

    String _suggestSku(String name) {
      // Generate SKU in format: PRD-XXXXXX-YXX (e.g., PRD-915311-D0S)
      final random1 = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(7);
      final random2 = String.fromCharCodes(
        List.generate(
          3,
          (i) => i == 0
              ? 48 +
                    DateTime.now().second %
                        10 // First char is number
              : 65 +
                    DateTime.now().millisecondsSinceEpoch %
                        26, // Last two are uppercase letters
        ),
      );
      return 'PRD-$random1-$random2';
    }

    var supplierId = await ref.read(supplierIdProvider.future);

    // If supplierId is null, try to find it using user data
    if (supplierId == null) {
      try {
        final me = await ref.read(supplierMeProvider.future);
        final userData = me['data'] ?? me['user'] ?? me;
        if (userData is Map) {
          final userId = userData['id'] != null
              ? int.tryParse(userData['id'].toString())
              : null;
          if (userId != null) {
            print('Trying to find supplier by user ID: $userId');
            final api = ref.read(supplierApiProvider);
            supplierId = await api.findSupplierIdByUserId(userId);
          }
        }
      } catch (e) {
        print('Error finding supplier ID: $e');
      }
    }

    if (supplierId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا يمكن إضافة منتج: لم يتم العثور على بيانات المورد. يرجى التأكد من أنك مسجل كموّرد.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    print('Using supplier ID for new product: $supplierId');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'إضافة منتج',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double spacing = 12;
                          final double fieldWidth =
                              (constraints.maxWidth - (spacing * 2)) / 3;
                          InputDecoration _dec(String label) {
                            final scheme = Theme.of(context).colorScheme;
                            return InputDecoration(
                              labelText: label,
                              filled: true,
                              fillColor: scheme.surface.withOpacity(0.06),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: scheme.outline.withOpacity(0.15),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: scheme.outline.withOpacity(0.12),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: scheme.primary.withOpacity(0.35),
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: nameController,
                                      decoration: _dec('اسم المنتج *'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: skuController,
                                      decoration: _dec('SKU').copyWith(
                                        suffixIcon: IconButton(
                                          tooltip: 'توليد تلقائي',
                                          icon: const Icon(
                                            Icons.auto_fix_high_outlined,
                                          ),
                                          onPressed: () {
                                            final sku = _suggestSku(
                                              nameController.text,
                                            );
                                            skuController.text = sku;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: _dec('السعر *'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: stockController,
                                      keyboardType: TextInputType.number,
                                      decoration: _dec('المخزون *'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: minStockController,
                                      keyboardType: TextInputType.number,
                                      decoration: _dec('الحد الأدنى للمخزون *'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: DropdownButtonFormField<String>(
                                      value: status,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'active',
                                          child: Text('نشط'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'inactive',
                                          child: Text('غير نشط'),
                                        ),
                                      ],
                                      onChanged: (v) => status = v ?? 'active',
                                      decoration: _dec('الحالة'),
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final categoriesAsync = ref.watch(
                                        supplierCategoriesProvider,
                                      );
                                      return categoriesAsync.when(
                                        data: (categories) => SizedBox(
                                          width: fieldWidth,
                                          child: DropdownButtonFormField<int>(
                                            value:
                                                selectedCategoryId ??
                                                (categories.isNotEmpty
                                                    ? int.tryParse(
                                                        categories.first['id']
                                                            .toString(),
                                                      )
                                                    : null),
                                            isExpanded: true,
                                            decoration: _dec('التصنيف *'),
                                            items: categories
                                                .map((cat) {
                                                  return DropdownMenuItem<int>(
                                                    value: cat['id'] != null
                                                        ? int.tryParse(
                                                            cat['id']
                                                                .toString(),
                                                          )
                                                        : null,
                                                    child: Text(
                                                      cat['name']?.toString() ??
                                                          '',
                                                    ),
                                                  );
                                                })
                                                .where(
                                                  (item) => item.value != null,
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCategoryId = value;
                                              });
                                            },
                                          ),
                                        ),
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (_, __) => SizedBox(
                                          width: fieldWidth,
                                          child: DropdownButtonFormField<int>(
                                            value: null,
                                            isExpanded: true,
                                            decoration: _dec(
                                              'التصنيف * (خطأ في التحميل)',
                                            ),
                                            items: const [],
                                            onChanged: (_) {},
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: descController,
                                maxLines: 3,
                                decoration: _dec('الوصف'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final price = double.tryParse(
                            priceController.text.trim(),
                          );
                          final stock = int.tryParse(
                            stockController.text.trim(),
                          );
                          final minStock =
                              int.tryParse(minStockController.text.trim()) ?? 0;

                          if (name.isEmpty ||
                              price == null ||
                              stock == null ||
                              selectedCategoryId == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'يرجى إدخال جميع الحقول المطلوبة (الاسم، السعر، المخزون، والتصنيف)',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          final payload = {
                            'name': name,
                            'price': price,
                            'stock_quantity': stock,
                            'min_stock_level': minStock,
                            'category_id': selectedCategoryId,
                            'sku': skuController.text.trim().isEmpty
                                ? null
                                : skuController.text.trim(),
                            'description': descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            'status': status,
                            'supplier_id': supplierId,
                          };

                          try {
                            await ref
                                .read(supplierApiProvider)
                                .createProduct(payload);
                            Navigator.pop(context);
                            ref.invalidate(supplierProductsProvider);
                            ref.invalidate(supplierStatsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إضافة المنتج بنجاح'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('فشل الإضافة: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('حفظ'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBulkPriceUpdateSheet(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final productsAsync = ref.watch(supplierProductsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.35),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'لا توجد منتجات لتعديل أسعارها',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final TextEditingController percentageController =
              TextEditingController();

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.outline.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.35),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تعديل أسعار المنتجات',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: percentageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'نسبة التعديل (%)',
                            hintText: 'مثال: 10 لزيادة السعر 10%',
                            prefixIcon: const Icon(Icons.percent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colors.surfaceContainerHighest
                                .withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final percentage = double.tryParse(
                                percentageController.text,
                              );
                              if (percentage == null || percentage == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى إدخال نسبة صحيحة'),
                                  ),
                                );
                                return;
                              }

                              try {
                                final supplierApi = ref.read(
                                  supplierApiProvider,
                                );
                                for (var product in products) {
                                  final currentPrice = _parseDouble(
                                    product['price'],
                                  );
                                  final newPrice =
                                      currentPrice * (1 + percentage / 100);
                                  await supplierApi.updateProduct(
                                    product['id'],
                                    {'price': newPrice},
                                  );
                                }

                                Navigator.pop(context);
                                ref.invalidate(supplierProductsProvider);
                                ref.invalidate(supplierStatsProvider);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم تحديث أسعار ${products.length} منتج بنجاح',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('حدث خطأ: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('تطبيق التعديل'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text('خطأ: ${err.toString()}'),
        ),
      ),
    );
  }

  void _showBulkStockUpdateSheet(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final productsAsync = ref.watch(supplierProductsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.35),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'لا توجد منتجات لتحديث مخزونها',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.outline.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.35),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تحديث مخزون المنتجات',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'اختر منتج لتحديث مخزونه',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final stockController = TextEditingController(
                                text:
                                    product['stock_quantity']?.toString() ??
                                    '0',
                              );

                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(
                                    product['name'] ?? 'منتج غير محدد',
                                  ),
                                  subtitle: Text(
                                    'المخزون الحالي: ${product['stock_quantity'] ?? 0}',
                                  ),
                                  trailing: SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: stockController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'قيمة جديدة',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: colors
                                            .surfaceContainerHighest
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    final newStock = int.tryParse(
                                      stockController.text,
                                    );
                                    if (newStock == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'يرجى إدخال قيمة صحيحة',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      final supplierApi = ref.read(
                                        supplierApiProvider,
                                      );
                                      await supplierApi.updateProductStock(
                                        product['id'],
                                        newStock,
                                      );

                                      Navigator.pop(context);
                                      ref.invalidate(supplierProductsProvider);
                                      ref.invalidate(supplierStatsProvider);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'تم تحديث مخزون ${product['name']} بنجاح',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'حدث خطأ: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text('خطأ: ${err.toString()}'),
        ),
      ),
    );
  }
}
