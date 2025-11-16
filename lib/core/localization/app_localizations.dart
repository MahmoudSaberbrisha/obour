import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'languageArabic': 'العربية',
      'languageEnglish': 'English',
      'languageChange': 'تغيير اللغة',
      'themeToggleToLight': 'التبديل للوضع الفاتح',
      'themeToggleToDark': 'التبديل للوضع الداكن',

      // Navigation labels
      'navDashboard': 'لوحة التحكم',
      'navUsers': 'المستخدمون',
      'navOrders': 'الطلبات',
      'navReports': 'التقارير',
      'navProfile': 'الملف الشخصي',
      'navHome': 'الرئيسية',
      'navBuyerOrders': 'الطلبات',
      'navBuyerProfile': 'الملف الشخصي',
      'navCarrierShipments': 'الشحنات',
      'navCarrierHistory': 'السجل',
      'navCarrierProfile': 'الملف الشخصي',
      'navSupplierDashboard': 'لوحة التحكم',
      'navSupplierProducts': 'المنتجات',
      'navSupplierOrders': 'الطلبات',
      'navSupplierProfile': 'الملف الشخصي',

      // Profile strings
      'profileTitle': 'الملف الشخصي',
      'profileLogout': 'تسجيل الخروج',
      'profileLogoutTooltip': 'تسجيل الخروج',
      'profileLogoutQuestion': 'هل أنت متأكد من تسجيل الخروج؟',
      'profileCancel': 'إلغاء',
      'profileConfirmLogout': 'تسجيل الخروج',
      'profileAccountTab': 'بيانات الحساب',
      'profileEntityTab': 'بيانات الكيان',
      'profileUserName': 'اسم المستخدم',
      'profileEmail': 'البريد الإلكتروني',
      'profileRole': 'الدور/الصفة',
      'profilePhone': 'رقم الجوال',
      'profileAddress': 'العنوان',
      'profileRegion': 'المنطقة',
      'profileCity': 'المدينة',
      'profileIdType': 'نوع الهوية',
      'profileIdNumber': 'رقم الهوية',
      'profileStatus': 'حالة الحساب',
      'profileCreatedAt': 'تاريخ التسجيل',
      'profileLanguageTooltip': 'تغيير اللغة',
      'notAvailable': 'غير محدد',
      'profileLoadError': 'حدث خطأ في تحميل البيانات',
      // Admin dashboard strings
      'adminDashboardTitle': 'لوحة التحكم',
      'adminWelcome': 'مرحباً بك {name}',
      'adminStatSuppliersTitle': 'إجمالي الموردين',
      'adminStatSuppliersActive': '{count} نشط',
      'adminStatBuyersTitle': 'إجمالي المشترين',
      'adminStatBuyersActive': '{count} نشط',
      'adminStatCarriersTitle': 'إجمالي الناقلين',
      'adminStatCarriersActive': '{count} نشط',
      'adminStatOrdersTitle': 'إجمالي الطلبات',
      'adminStatOrdersCompleted': '{count} مكتمل',
      'adminStatOrdersInProgressTitle': 'الطلبات قيد التنفيذ',
      'adminStatOrdersPending': '{count} في الانتظار',
      'adminStatSuppliersActiveTitle': 'الموردين النشطين',
      'adminStatSuppliersInactive': '{count} غير نشط',
      'adminOrdersChartTitle': 'حالة الطلبات',
      'adminActivitySummaryTitle': 'ملخص النشاط',
      'adminSummarySuppliers': 'الموردين',
      'adminSummaryBuyers': 'المشترين',
      'adminSummaryCarriers': 'الناقلين',
      'adminSummaryTotalActive': 'إجمالي النشطين',
      'adminNoData': 'لا توجد بيانات',
      'adminNoActivities': 'لا توجد نشاطات',
      'adminTopRegionsTitle': 'أكثر المناطق نشاطاً',
      'adminRecentActivitiesTitle': 'النشاطات الأخيرة',
      'adminReportsTitle': 'التقارير',
      'adminReportsManagement': 'إدارة التقارير',
      'adminReportsManagementDesc': 'مركز شامل لإدارة ومراقبة جميع تقاريرك',
      'adminReportsCompletionRate': 'معدل الإنجاز الإجمالي',
      'adminReportsCategories': 'فئات التقارير',
      'adminReportsViewAll': 'عرض الكل',
      'adminReportsRecent': 'التقارير الحديثة',
      'adminReportsNone': 'لا توجد تقارير',
      'commonNoData': 'لا توجد بيانات',
      'commonNoProducts': 'لا توجد منتجات',
      'commonNoOrders': 'لا توجد طلبات',
      'commonLoadProductsError': 'خطأ في تحميل المنتجات',
      'commonLoadOrdersError': 'خطأ في تحميل الطلبات',
      'commonUnknownCustomer': 'عميل غير محدد',
      'commonUnknownSupplier': 'مورد غير محدد',
      'commonUnknownBuyer': 'مشتري غير محدد',
      'statusActive': 'نشط',
      'statusInactive': 'غير نشط',
      'statusOutOfStock': 'نفد المخزون',
      'statusDiscontinued': 'متوقف',
      'statusPending': 'قيد الانتظار',
      'statusProcessing': 'قيد المعالجة',
      'statusInProgress': 'قيد التنفيذ',
      'statusCompleted': 'مكتمل',
      'statusDelivered': 'تم التوصيل',
      'statusCancelled': 'ملغي',
      'statusReview': 'قيد المراجعة',
      'statusNew': 'جديد',
      'statusUnknown': 'غير معروف',
      'labelProducts': 'المنتجات',
      'labelOrders': 'الطلبات',
      'labelAmount': 'المبلغ',
      'labelStatus': 'الحالة',
      'labelPaymentMethod': 'طريقة الدفع',
      'labelCity': 'المدينة',
      'labelRegion': 'المنطقة',
      'labelAddress': 'العنوان',
      'labelNotes': 'الملاحظات',
      'labelItemsCount': 'عدد العناصر',
      'labelPhone': 'رقم الجوال',
      'labelBuyer': 'المشتري',
      'labelSupplier': 'المورد',
      'labelCustomer': 'العميل',
      'labelOrderNumber': 'رقم الطلب',
      'labelOrderDetails': 'تفاصيل الطلب',
      'labelProductDetails': 'تفاصيل المنتج',
      'labelProductName': 'اسم المنتج',
      'labelPrice': 'السعر',
      'labelStock': 'المخزون',
      'labelMinStock': 'الحد الأدنى',
      'labelCategory': 'التصنيف',
      'labelDescription': 'الوصف',
      'labelAvailableQuantity': 'الكمية المتاحة',
      'labelSoldQuantity': 'الكمية المباعة',
      'labelCreatedAt': 'تاريخ الإنشاء',
      'labelUpdatedAt': 'آخر تحديث',
      'labelOrder': 'الطلب',
      'stockWithCount': 'المخزون: {count}',
      'amountWithValue': 'المبلغ: {amount}',
      'statusWithValue': 'الحالة: {status}',
      'dateWithValue': 'التاريخ: {date}',
      'customerWithName': 'العميل: {name}',
      'buyerWithName': 'المشتري: {name}',
      'supplierWithName': 'المورد: {name}',
      'phoneWithValue': 'الجوال: {phone}',
      'orderNumberFormatted': 'طلب #{number}',
      'itemsCountWithValue': 'عدد العناصر: {count}',
      'priceWithCurrency': 'السعر: {amount}',
      'minStockWithValue': 'الحد الأدنى: {count}',
      'availableQuantityWithValue': 'الكمية المتاحة: {count}',
      'soldQuantityWithValue': 'الكمية المباعة: {count}',
    },
    'en': {
      'languageArabic': 'Arabic',
      'languageEnglish': 'English',
      'languageChange': 'Change language',
      'themeToggleToLight': 'Switch to Light Mode',
      'themeToggleToDark': 'Switch to Dark Mode',

      // Navigation labels
      'navDashboard': 'Dashboard',
      'navUsers': 'Users',
      'navOrders': 'Orders',
      'navReports': 'Reports',
      'navProfile': 'Profile',
      'navHome': 'Home',
      'navBuyerOrders': 'Orders',
      'navBuyerProfile': 'Profile',
      'navCarrierShipments': 'Shipments',
      'navCarrierHistory': 'History',
      'navCarrierProfile': 'Profile',
      'navSupplierDashboard': 'Dashboard',
      'navSupplierProducts': 'Products',
      'navSupplierOrders': 'Orders',
      'navSupplierProfile': 'Profile',

      // Profile strings
      'profileTitle': 'Profile',
      'profileLogout': 'Logout',
      'profileLogoutTooltip': 'Logout',
      'profileLogoutQuestion': 'Are you sure you want to log out?',
      'profileCancel': 'Cancel',
      'profileConfirmLogout': 'Logout',
      'profileAccountTab': 'Account Information',
      'profileEntityTab': 'Entity Information',
      'profileUserName': 'Username',
      'profileEmail': 'Email',
      'profileRole': 'Role',
      'profilePhone': 'Phone Number',
      'profileAddress': 'Address',
      'profileRegion': 'Region',
      'profileCity': 'City',
      'profileIdType': 'Identification Type',
      'profileIdNumber': 'Identification Number',
      'profileStatus': 'Account Status',
      'profileCreatedAt': 'Created At',
      'profileLanguageTooltip': 'Change language',
      'notAvailable': 'Not available',
      'profileLoadError': 'Failed to load profile data',
      // Admin dashboard strings
      'adminDashboardTitle': 'Dashboard',
      'adminWelcome': 'Welcome {name}',
      'adminStatSuppliersTitle': 'Total Suppliers',
      'adminStatSuppliersActive': '{count} active',
      'adminStatBuyersTitle': 'Total Buyers',
      'adminStatBuyersActive': '{count} active',
      'adminStatCarriersTitle': 'Total Carriers',
      'adminStatCarriersActive': '{count} active',
      'adminStatOrdersTitle': 'Total Orders',
      'adminStatOrdersCompleted': '{count} completed',
      'adminStatOrdersInProgressTitle': 'Orders in Progress',
      'adminStatOrdersPending': '{count} pending',
      'adminStatSuppliersActiveTitle': 'Active Suppliers',
      'adminStatSuppliersInactive': '{count} inactive',
      'adminOrdersChartTitle': 'Order Statuses',
      'adminActivitySummaryTitle': 'Activity Summary',
      'adminSummarySuppliers': 'Suppliers',
      'adminSummaryBuyers': 'Buyers',
      'adminSummaryCarriers': 'Carriers',
      'adminSummaryTotalActive': 'Total Active',
      'adminNoData': 'No data available',
      'adminNoActivities': 'No recent activity',
      'adminTopRegionsTitle': 'Top Regions',
      'adminRecentActivitiesTitle': 'Recent Activities',
      'adminReportsTitle': 'Reports',
      'adminReportsManagement': 'Reports Management',
      'adminReportsManagementDesc':
          'A central hub to manage and monitor all your reports',
      'adminReportsCompletionRate': 'Overall completion rate',
      'adminReportsCategories': 'Report Categories',
      'adminReportsViewAll': 'View all',
      'adminReportsRecent': 'Recent Reports',
      'adminReportsNone': 'No reports available',
      'commonNoData': 'No data available',
      'commonNoProducts': 'No products available',
      'commonNoOrders': 'No orders available',
      'commonLoadProductsError': 'Failed to load products',
      'commonLoadOrdersError': 'Failed to load orders',
      'commonUnknownCustomer': 'Unknown customer',
      'commonUnknownSupplier': 'Unknown supplier',
      'commonUnknownBuyer': 'Unknown buyer',
      'statusActive': 'Active',
      'statusInactive': 'Inactive',
      'statusOutOfStock': 'Out of stock',
      'statusDiscontinued': 'Discontinued',
      'statusPending': 'Pending',
      'statusProcessing': 'Processing',
      'statusInProgress': 'In progress',
      'statusCompleted': 'Completed',
      'statusDelivered': 'Delivered',
      'statusCancelled': 'Cancelled',
      'statusReview': 'Under review',
      'statusNew': 'New',
      'statusUnknown': 'Unknown',
      'labelProducts': 'Products',
      'labelOrders': 'Orders',
      'labelAmount': 'Amount',
      'labelStatus': 'Status',
      'labelPaymentMethod': 'Payment method',
      'labelCity': 'City',
      'labelRegion': 'Region',
      'labelAddress': 'Address',
      'labelNotes': 'Notes',
      'labelItemsCount': 'Items count',
      'labelPhone': 'Phone',
      'labelBuyer': 'Buyer',
      'labelSupplier': 'Supplier',
      'labelCustomer': 'Customer',
      'labelOrderNumber': 'Order number',
      'labelOrderDetails': 'Order details',
      'labelProductDetails': 'Product details',
      'labelProductName': 'Product name',
      'labelPrice': 'Price',
      'labelStock': 'Stock',
      'labelMinStock': 'Minimum stock',
      'labelCategory': 'Category',
      'labelDescription': 'Description',
      'labelAvailableQuantity': 'Available quantity',
      'labelSoldQuantity': 'Sold quantity',
      'labelCreatedAt': 'Created at',
      'labelUpdatedAt': 'Last updated',
      'labelOrder': 'Order',
      'stockWithCount': 'Stock: {count}',
      'amountWithValue': 'Amount: {amount}',
      'statusWithValue': 'Status: {status}',
      'dateWithValue': 'Date: {date}',
      'customerWithName': 'Customer: {name}',
      'buyerWithName': 'Buyer: {name}',
      'supplierWithName': 'Supplier: {name}',
      'phoneWithValue': 'Phone: {phone}',
      'orderNumberFormatted': 'Order #{number}',
      'itemsCountWithValue': 'Items: {count}',
      'priceWithCurrency': 'Price: {amount}',
      'minStockWithValue': 'Minimum stock: {count}',
      'availableQuantityWithValue': 'Available quantity: {count}',
      'soldQuantityWithValue': 'Sold quantity: {count}',
    },
  };

  String translate(String key, {Map<String, String> params = const {}}) {
    var value = _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['ar']?[key] ??
        key;

    if (params.isEmpty) return value;

    params.forEach((token, replacement) {
      value = value.replaceAll('{$token}', replacement);
    });
    return value;
  }

  String formatCurrency(num amount) {
    final formatted = amount.toStringAsFixed(2);
    if (locale.languageCode == 'ar') {
      return '$formatted ر.س';
    }
    return 'SAR $formatted';
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

