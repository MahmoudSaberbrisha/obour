import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();

  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  String idType = 'بطاقة شخصية';
  final idNumberController = TextEditingController();
  bool isActive = false;
  bool _isLoading = false;

  bool get _isTab1Valid =>
      fullNameController.text.trim().isNotEmpty &&
      userNameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty;

  bool get _isTab2Valid => passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateToRoleSelection() async {
    // Just navigate to role selection without creating account
    // Convert idType from Arabic to English for API
    String idTypeApi = 'card'; // Default
    if (idType == 'هوية وطنية') {
      idTypeApi = 'sgl';
    } else if (idType == 'بطاقة شخصية') {
      idTypeApi = 'card';
    }

    final userArgs = {
      'name': fullNameController.text.trim(),
      'username': userNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'password': passwordController.text.trim(),
      'identification_type': idTypeApi,
      'identification_number': idNumberController.text.trim(),
    };

    print('RegisterPage - Navigating to role selection with data: $userArgs');
    Navigator.of(
      context,
    ).pushReplacementNamed('/roleSelection', arguments: userArgs);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Top hero image (same style as Login)
            SizedBox(
              height: 400,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/Rectangle 350.png',
                      fit: BoxFit.cover,
                    ),
                    Container(color: Colors.black.withOpacity(0.35)),
                  ],
                ),
              ),
            ),
            // Optional overlay heading (kept subtle for Register)
            Positioned.fill(
              top: 64,
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 44),
                    const SizedBox(height: 8),
                    Text(
                      'إنشاء حساب جديد',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Card with tabs overlapping the hero
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 310, 16, 16),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withOpacity(0.65),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                child: TabBar(
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.black54,
                                  tabs: const [
                                    Tab(text: 'البيانات الأساسية'),
                                    Tab(text: 'التواصل والحساب'),
                                    Tab(text: 'الهوية والمرفقات'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (contentCtx) {
                                  final t = DefaultTabController.of(contentCtx);
                                  return AnimatedBuilder(
                                    animation: t,
                                    builder: (context, _) {
                                      final current = t.index;
                                      return AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        child: current == 0
                                            ? _BasicInfoTab(
                                                key: const ValueKey('tab0'),
                                                fullNameController:
                                                    fullNameController,
                                                userNameController:
                                                    userNameController,
                                                emailController:
                                                    emailController,
                                                phoneController:
                                                    phoneController,
                                              )
                                            : current == 1
                                            ? _ContactAccountTab(
                                                key: const ValueKey('tab1'),
                                                addressController:
                                                    addressController,
                                                passwordController:
                                                    passwordController,
                                                idType: idType,
                                                onIdTypeChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          idType = v ?? idType,
                                                    ),
                                                idNumberController:
                                                    idNumberController,
                                              )
                                            : _IdentityAttachmentsTab(
                                                key: const ValueKey('tab2'),
                                                isActive: isActive,
                                                onActiveChanged: (v) =>
                                                    setState(
                                                      () => isActive = v,
                                                    ),
                                              ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Button sits right beneath fields
                              Builder(
                                builder: (btnCtx) {
                                  final tabController = DefaultTabController.of(
                                    btnCtx,
                                  );
                                  return AnimatedBuilder(
                                    animation: tabController,
                                    builder: (context, _) {
                                      final lastIndex =
                                          tabController.length - 1;
                                      final isLast =
                                          tabController.index == lastIndex;
                                      return SizedBox(
                                        width: double.infinity,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.85),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.3),
                                                blurRadius: 14,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              shadowColor: Colors.transparent,
                                              backgroundColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                            ),
                                            onPressed: () {
                                              bool canProceed = false;

                                              if (tabController.index == 0) {
                                                canProceed = _isTab1Valid;
                                                if (!canProceed) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'الرجاء إدخال جميع الحقول المطلوبة',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else if (tabController.index ==
                                                  1) {
                                                canProceed = _isTab2Valid;
                                                if (!canProceed) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'الرجاء إدخال كلمة المرور',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                canProceed = true;
                                              }

                                              if (canProceed) {
                                                if (!isLast) {
                                                  tabController.animateTo(
                                                    tabController.index + 1,
                                                  );
                                                } else {
                                                  _navigateToRoleSelection();
                                                }
                                              }
                                            },
                                            child: _isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Text(
                                                    isLast
                                                        ? 'متابعة'
                                                        : 'متابعة',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicInfoTab extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  const _BasicInfoTab({
    super.key,
    required this.fullNameController,
    required this.userNameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: 'الاسم الكامل *',
          child: _input(
            context,
            fullNameController,
            'الاسم الكامل',
            icon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'اسم المستخدم *',
          child: _input(
            context,
            userNameController,
            'اسم المستخدم',
            icon: Icons.alternate_email,
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'البريد الإلكتروني *',
          child: _input(
            context,
            emailController,
            'example@mail.com',
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            icon: Icons.mail_outline,
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'رقم الجوال',
          child: _input(
            context,
            phoneController,
            '05xxxxxxxx',
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            icon: Icons.phone_outlined,
          ),
        ),
      ],
    );
  }

  Widget _input(
    BuildContext context,
    TextEditingController c,
    String hint, {
    TextInputType? keyboardType,
    TextDirection? textDirection,
    IconData? icon,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ContactAccountTab extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final String idType;
  final ValueChanged<String?> onIdTypeChanged;
  final TextEditingController idNumberController;
  const _ContactAccountTab({
    super.key,
    required this.addressController,
    required this.passwordController,
    required this.idType,
    required this.onIdTypeChanged,
    required this.idNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: 'العنوان',
          child: _input(
            context,
            addressController,
            'المدينة، الحي، الشارع',
            icon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'كلمة المرور *',
          child: _input(
            context,
            passwordController,
            '••••••••',
            obscure: true,
            icon: Icons.lock_outline,
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'نوع الهوية',
          child: DropdownButtonFormField<String>(
            value: idType,
            items: const [
              DropdownMenuItem(
                value: 'بطاقة شخصية',
                child: Text('بطاقة شخصية'),
              ),
              DropdownMenuItem(value: 'سجل تجاري', child: Text('سجل تجاري')),
            ],
            onChanged: onIdTypeChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'رقم الهوية',
          child: _input(
            context,
            idNumberController,
            'رقم الهوية',
            icon: Icons.badge_outlined,
          ),
        ),
      ],
    );
  }

  Widget _input(
    BuildContext context,
    TextEditingController c,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    IconData? icon,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      textDirection: textDirection,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon)
            : (obscure ? const Icon(Icons.lock_outline) : null),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _IdentityAttachmentsTab extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  const _IdentityAttachmentsTab({
    super.key,
    required this.isActive,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // الحالة
        Row(
          children: [
            Switch(
              value: isActive,
              onChanged: onActiveChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('الحالة: غير نشط/نشط'),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'صورة المستخدم',
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.image_outlined),
            label: const Text('إرفاق صورة'),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'مرفق الهوية',
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.attach_file),
            label: const Text('إرفاق ملف الهوية'),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
