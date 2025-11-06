import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingSeenProvider = StateProvider<bool>((ref) => false);
final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);
