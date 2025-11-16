import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_mode.dart';
import 'supplier_home_page.dart';
import 'supplier_providers.dart';
import '../../../core/widgets/modern_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/profile_page.dart';
import '../../../core/config/env.dart';

class SupplierMainPage extends StatefulWidget {
  const SupplierMainPage({super.key});

  @override
  State<SupplierMainPage> createState() => _SupplierMainPageState();
}

class _SupplierMainPageState extends State<SupplierMainPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SupplierHomePage(),
    const _ProductsPage(),
    const _OrdersPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: isDark ? 12 : 6,
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            height: 80,
            elevation: 10,
            backgroundColor: colors.surface.withOpacity(isDark ? 0.9 : 1),
            indicatorColor: colors.primary.withOpacity(0.18),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: l10n.translate('navSupplierDashboard'),
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: l10n.translate('navSupplierProducts'),
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: l10n.translate('navSupplierOrders'),
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: l10n.translate('navSupplierProfile'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const ThemeModeToggleFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _ProductsPage extends ConsumerWidget {
  const _ProductsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final productsAsync = ref.watch(supplierProductsProvider);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.translate('labelProducts')),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.translate('commonLoadProductsError'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.error),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text(
                l10n.translate('commonNoProducts'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
              final imageUrl = _resolveImageUrlLocal(
                p['image_url']?.toString(),
              );

              return ModernCard(
                child: InkWell(
                  onTap: () =>
                      _ProductsPageHelper._showProductDetails(context, p),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: colors.primary,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.sell_outlined,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.formatCurrency(price),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.storage_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.translate(
                                    'stockWithCount',
                                    params: {'count': stock.toString()},
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: colors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            _localizedProductStatus(context, status),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _localizedProductStatus(BuildContext context, String status) {
  final l10n = context.l10n;
  switch (status.toLowerCase()) {
    case 'active':
      return l10n.translate('statusActive');
    case 'inactive':
      return l10n.translate('statusInactive');
    case 'out_of_stock':
      return l10n.translate('statusOutOfStock');
    case 'discontinued':
      return l10n.translate('statusDiscontinued');
    default:
      return status;
  }
}

String _resolveImageUrlLocal(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final base = Env.apiBaseUrl;
  final uri = Uri.parse(base);
  final origin =
      '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  if (url.startsWith('/')) {
    return '$origin$url';
  }
  return '$origin/$url';
}

class _OrdersPage extends ConsumerWidget {
  const _OrdersPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final ordersAsync = ref.watch(supplierOrdersProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.translate('labelOrders')),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.translate('commonLoadOrdersError'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.error),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Text(
                l10n.translate('commonNoOrders'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['order_number'] ?? order['id'] ?? '-';
              final status = order['status']?.toString() ?? 'pending';
              final date = order['createdAt'] ?? order['order_date'];
              final price = order['total_price'];
              final buyerName =
                  order['Buyer']?['name']?.toString() ??
                  l10n.translate('commonUnknownCustomer');

              return ModernCard(
                child: InkWell(
                  onTap: () => _showOrderDetails(context, order),
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: colors.primary,
                      ),
                    ),
                    title: Text(
                        l10n.translate(
                          'orderNumberFormatted',
                          params: {'number': orderId.toString()},
                        )),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate(
                            'customerWithName',
                            params: {'name': buyerName},
                          ),
                        ),
                        if (date != null)
                          Text(
                            _formatOrderDate(date.toString()),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (price != null)
                          Text(
                            l10n.translate(
                              'amountWithValue',
                              params: {
                                'amount': l10n.formatCurrency(
                                  _parseDouble(price),
                                ),
                              },
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: colors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _localizedOrderStatus(context, status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _localizedOrderStatus(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.translate('statusPending');
      case 'processing':
        return l10n.translate('statusProcessing');
      case 'completed':
      case 'delivered':
        return l10n.translate('statusCompleted');
      case 'cancelled':
        return l10n.translate('statusCancelled');
      default:
        return l10n.translate('statusUnknown');
    }
  }

  String _formatOrderDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date;
    }
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                            context.l10n.translate('labelOrderDetails'),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _detailCard(
                        context,
                        context.l10n.translate('labelOrderNumber'),
                        '${order['order_number'] ?? order['id']}',
                        Icons.receipt_long_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelCustomer'),
                        order['Buyer']?['name'] ??
                            context.l10n.translate('commonUnknownCustomer'),
                        Icons.person_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelStatus'),
                        _localizedOrderStatus(
                          context,
                          order['status']?.toString() ?? '',
                        ),
                        Icons.info_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelAmount'),
                        context.l10n.formatCurrency(
                          _parseDouble(order['total_price']),
                        ),
                        Icons.attach_money_rounded,
                      ),
                      if (order['createdAt'] != null) ...[
                        const SizedBox(height: 12),
                        _detailCard(
                          context,
                          context.l10n.translate('labelCreatedAt'),
                          _formatOrderDate(order['createdAt'].toString()),
                          Icons.calendar_today_rounded,
                        ),
                      ],
                      if (order['Buyer']?['jwal'] != null) ...[
                        const SizedBox(height: 12),
                        _detailCard(
                          context,
                          context.l10n.translate('labelPhone'),
                          order['Buyer']['jwal'],
                          Icons.phone_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsPageHelper {
  static void _showProductDetails(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = product['name']?.toString() ?? '-';
    final sku = product['sku']?.toString() ?? '-';
    final price = product['price'];
    final stock =
        product['stock_quantity'] ?? product['stock'] ?? product['quantity'];
    final minStock = product['min_stock_level'] ?? 0;
    final status = product['status']?.toString() ?? 'active';
    final desc = product['description']?.toString();
    final categoryName = product['Category']?['name']?.toString() ??
        context.l10n.translate('notAvailable');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                            context.l10n.translate('labelProductDetails'),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _detailCard(
                        context,
                        context.l10n.translate('labelProductName'),
                        name,
                        Icons.inventory_2_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(context, 'SKU', sku, Icons.qr_code_rounded),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelPrice'),
                        context.l10n
                            .formatCurrency(_parseDouble(price)),
                        Icons.attach_money_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelStock'),
                        stock.toString(),
                        Icons.storage_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelMinStock'),
                        minStock.toString(),
                        Icons.trending_down_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelCategory'),
                        categoryName,
                        Icons.category_rounded,
                      ),
                      const SizedBox(height: 12),
                      _detailCard(
                        context,
                        context.l10n.translate('labelStatus'),
                        _localizedProductStatus(context, status),
                        Icons.info_rounded,
                      ),
                      if (desc != null && desc.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _detailCard(
                          context,
                          context.l10n.translate('labelDescription'),
                          desc,
                          Icons.description_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Widget _detailCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
