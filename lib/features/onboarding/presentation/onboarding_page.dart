import 'package:flutter/material.dart';
import '../../../core/router/routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final headline = Theme.of(context).textTheme.headlineLarge;
    final body = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 5),
              // Hero image from assets
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/wmremove-transformed 2.png',
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: headline,
                        children: [
                          const TextSpan(text: 'تسوق الحين و توصيل '),
                          TextSpan(
                            text: 'علينا',
                            style: headline?.copyWith(color: colors.primary),
                          ),
                          const TextSpan(text: ' طلبك'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يا هلا فيك! انضم لينا الآن واستمتع بتجربة تسوق ممتعة وسهلة عبر تطبيقنا',
                      style: body?.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.login),
                child: const Text('ابدأ الان'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
