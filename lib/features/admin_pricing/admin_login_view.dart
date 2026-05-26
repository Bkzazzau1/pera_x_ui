import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import 'data/admin_auth_service.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final usernameController = TextEditingController(text: 'admin');
  final accessCodeController = TextEditingController();
  final authService = AdminAuthService();

  bool loading = false;
  bool hideCode = true;

  @override
  void dispose() {
    usernameController.dispose();
    accessCodeController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final accessCode = accessCodeController.text.trim();

    if (username.isEmpty || accessCode.isEmpty) {
      showMessage('Enter admin username and access code.');
      return;
    }

    setState(() => loading = true);

    try {
      await authService.login(username: username, accessCode: accessCode);
      if (!mounted) return;
      context.go('/admin-pricing');
    } catch (error) {
      if (!mounted) return;
      showMessage(error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeraXColors.darkBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PeraXColors.darkBlue,
              Color(0xFF071A35),
              Color(0xFF020617),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: GlassCard(
                radius: 30,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: PeraXColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PeraXColors.glassBorder),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: PeraXColors.cyan,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Admin Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login to manage backend Credit charges, exchange rates and number subscriptions.',
                      style: TextStyle(color: Colors.white60, height: 1.45),
                    ),
                    const SizedBox(height: 22),
                    _AdminInput(
                      controller: usernameController,
                      label: 'Admin username',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _AdminInput(
                      controller: accessCodeController,
                      label: 'Admin access code',
                      icon: Icons.lock_outline_rounded,
                      obscureText: hideCode,
                      suffix: IconButton(
                        onPressed: () => setState(() => hideCode = !hideCode),
                        icon: Icon(
                          hideCode ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: loading ? null : login,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: PeraXColors.darkBlue,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(loading ? 'VERIFYING ADMIN' : 'LOGIN TO ADMIN'),
                        style: FilledButton.styleFrom(
                          backgroundColor: PeraXColors.cyan,
                          foregroundColor: PeraXColors.darkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Do not store admin access code in Flutter. It must remain in backend environment only.',
                      style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;

  const _AdminInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: PeraXColors.cyan),
        suffixIcon: suffix,
        filled: true,
        fillColor: PeraXColors.surfaceBlue.withValues(alpha: 0.55),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: PeraXColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: PeraXColors.cyan),
        ),
      ),
    );
  }
}
