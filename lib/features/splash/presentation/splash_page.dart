import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/routes.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/application/auth_controller.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = SecureStorage();
      final token = await storage.readAccessToken();
      if (!context.mounted) return;

      if (token != null && token.isNotEmpty) {
        // Get person type and navigate to the appropriate home page
        final controller = ref.read(authControllerProvider.notifier);
        final personType = await controller.getUserPersonType();

        if (!context.mounted) return;

        String route;
        switch (personType) {
          case 'client':
            route = Routes.buyerHome;
            break;
          case 'supplier':
            route = Routes.supplierHome;
            break;
          case 'carrier':
            route = Routes.carrierHome;
            break;
          case 'admin':
            route = Routes.adminHome;
            break;
          default:
            route = Routes.login;
        }

        Navigator.of(context).pushReplacementNamed(route);
      } else {
        unawaited(
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(Routes.onboarding);
            }
          }),
        );
      }
    });

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    colors.primary.withOpacity(0.75),
                    colors.primary.withOpacity(0.75),
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 70,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.75),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 24,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
