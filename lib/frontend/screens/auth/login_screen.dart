import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/screens/auth/forgot_password_modal.dart';
import 'package:erp_software/frontend/widgets/common/server_config_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@erp.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ErpToast.showSuccess(
          context,
          'Welcome back, ${authProvider.user?.email}!',
          title: 'Login Successful',
        );
      } else if (authProvider.errorMessage != null) {
        ErpToast.showError(
          context,
          authProvider.errorMessage!,
          title: 'Login Failed',
        );
      }
    }
  }

  void _openForgotPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ForgotPasswordModal(
        initialEmail: _emailController.text.trim(),
        onPasswordResetSuccess: (email) {
          setState(() {
            _emailController.text = email;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2E), Color(0xFF2A2A40)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: const Color(0xFF2D2D44),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 44,
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.dns_outlined, color: Color(0xFFA29BFE), size: 20),
                            tooltip: 'Configure Server IP',
                            onPressed: () => ServerConfigDialog.show(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'ERP Portal Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to access Auth & Employee modules',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email or Employee ID',
                          labelStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF6C5CE7)),
                          filled: true,
                          fillColor: const Color(0xFF1E1E2E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your registered email or Employee ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF6C5CE7)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E1E2E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFFA29BFE),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFFA29BFE)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Quick Sign-in (Password: admin123):',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade300),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ActionChip(
                                  backgroundColor: const Color(0xFF1E293B),
                                  side: const BorderSide(color: Color(0xFF3B82F6)),
                                  avatar: const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF60A5FA)),
                                  label: const Text('Gym SuperAdmin', style: TextStyle(fontSize: 11, color: Colors.white)),
                                  onPressed: () {
                                    setState(() {
                                      _emailController.text = 'superadmingym@gmail.com';
                                      _passwordController.text = 'admin123';
                                    });
                                  },
                                ),
                                ActionChip(
                                  backgroundColor: const Color(0xFF1E293B),
                                  side: const BorderSide(color: Color(0xFF10B981)),
                                  avatar: const Icon(Icons.storefront_rounded, size: 14, color: Color(0xFF34D399)),
                                  label: const Text('Retail SuperAdmin', style: TextStyle(fontSize: 11, color: Colors.white)),
                                  onPressed: () {
                                    setState(() {
                                      _emailController.text = 'superadminretail@gmail.com';
                                      _passwordController.text = 'admin123';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
