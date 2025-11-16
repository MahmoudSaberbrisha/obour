import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_notifier.dart';
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
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('profileTitle')),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: l10n.translate('profileLanguageTooltip'),
            icon: const Icon(Icons.language),
            onSelected: (selectedLocale) {
              ref.read(localeProvider.notifier).setLocale(selectedLocale);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('ar'),
                child: Row(
                  children: [
                    if (locale.languageCode == 'ar')
                      const Icon(Icons.check, size: 16),
                    if (locale.languageCode == 'ar')
                      const SizedBox(width: 8),
                    Text(l10n.translate('languageArabic')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: const Locale('en'),
                child: Row(
                  children: [
                    if (locale.languageCode == 'en')
                      const Icon(Icons.check, size: 16),
                    if (locale.languageCode == 'en')
                      const SizedBox(width: 8),
                    Text(l10n.translate('languageEnglish')),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.translate('profileLogout')),
                  content: Text(l10n.translate('profileLogoutQuestion')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.translate('profileCancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.translate('profileConfirmLogout')),
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
            tooltip: l10n.translate('profileLogoutTooltip'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (data) => DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).textTheme.bodySmall?.color,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(text: l10n.translate('profileAccountTab')),
                  Tab(text: l10n.translate('profileEntityTab')),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: const [_AccountInfoTab(), _EntityInfoTab()],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text(l10n.translate('profileLoadError'))),
      ),
    );
  }
}

class _AccountInfoTab extends ConsumerWidget {
  const _AccountInfoTab();

  String _valueOrFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty || value == 'null') {
      return fallback;
    }
    return value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final basic = ref.watch(userProfileProvider).value ?? {};
    final full = ref.watch(userFullProfileProvider).value ?? {};

    final role = _valueOrFallback(
      (full['role'] ?? full['person_type'])?.toString(),
      l10n.translate('notAvailable'),
    );
    final phone = _valueOrFallback(
      (full['jwal'] ?? full['phone'])?.toString(),
      l10n.translate('notAvailable'),
    );
    final address = _valueOrFallback(
      (full['address'] ?? '')?.toString(),
      l10n.translate('notAvailable'),
    );
    final region = _valueOrFallback(
      (full['Region']?['name'] ?? full['region']?['name'] ?? '')?.toString(),
      l10n.translate('notAvailable'),
    );
    final city = _valueOrFallback(
      (full['City']?['name'] ?? full['city']?['name'] ?? '')?.toString(),
      l10n.translate('notAvailable'),
    );
    final status = _valueOrFallback(
      (full['active'] ?? full['status'])?.toString(),
      l10n.translate('notAvailable'),
    );
    final createdAt = _valueOrFallback(
      (full['createdAt'] ?? full['created_at'])?.toString(),
      l10n.translate('notAvailable'),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: l10n.translate('profileUserName'),
          value: _valueOrFallback(
            basic['userName'],
            l10n.translate('notAvailable'),
          ),
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileEmail'),
          value: _valueOrFallback(
            basic['userEmail'],
            l10n.translate('notAvailable'),
          ),
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileRole'),
          value: role,
          icon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profilePhone'),
          value: phone,
          icon: Icons.phone_android_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileAddress'),
          value: address,
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileRegion'),
          value: region,
          icon: Icons.map_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileCity'),
          value: city,
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileIdType'),
          value: _valueOrFallback(
            basic['identificationType'],
            l10n.translate('notAvailable'),
          ),
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileIdNumber'),
          value: _valueOrFallback(
            basic['identificationNumber'],
            l10n.translate('notAvailable'),
          ),
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileStatus'),
          value: status,
          icon: Icons.shield_moon_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileCreatedAt'),
          value: createdAt,
          icon: Icons.calendar_month_outlined,
        ),
      ],
    );
  }
}

class _EntityInfoTab extends ConsumerWidget {
  const _EntityInfoTab();

  String _valueOrFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty || value == 'null') {
      return fallback;
    }
    return value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(userProfileProvider).value ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: l10n.translate('profileIdType'),
          value: _valueOrFallback(
            data['identificationType'],
            l10n.translate('notAvailable'),
          ),
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: l10n.translate('profileIdNumber'),
          value: _valueOrFallback(
            data['identificationNumber'],
            l10n.translate('notAvailable'),
          ),
          icon: Icons.confirmation_number_outlined,
        ),
      ],
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
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
    );
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(value, style: valueStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
