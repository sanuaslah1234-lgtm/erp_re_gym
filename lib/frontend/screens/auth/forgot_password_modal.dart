import 'dart:async';
import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

enum ForgotPasswordStep { email, otp, newPassword, success }

class ForgotPasswordModal extends StatefulWidget {
  final String initialEmail;
  final Function(String email)? onPasswordResetSuccess;

  const ForgotPasswordModal({
    super.key,
    this.initialEmail = '',
    this.onPasswordResetSuccess,
  });

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;

  late TextEditingController _emailController;
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _autofillOtp(String code) {
    if (code.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = code[i];
      }
      setState(() {});
    }
  }

  Future<void> _submitEmail() async {
    if (_emailFormKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final otpCode = await authProvider.forgotPassword(email);

      if (!mounted) return;

      if (otpCode != null) {
        _startResendTimer();
        setState(() => _currentStep = ForgotPasswordStep.otp);
        ErpToast.showInfo(
          context,
          'OTP sent to $email. Please check your inbox.',
          title: 'OTP Dispatched',
        );
      } else if (authProvider.errorMessage != null) {
        ErpToast.showError(
          context,
          authProvider.errorMessage!,
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    final email = _emailController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final otpCode = await authProvider.forgotPassword(email);

    if (!mounted) return;

    if (otpCode != null) {
      _startResendTimer();
      ErpToast.showInfo(
        context,
        'New OTP code sent to $email',
        title: 'OTP Resent',
      );
    }
  }

  Future<void> _submitOtp() async {
    final otp = _otpCode;
    if (otp.length < 6) {
      ErpToast.showWarning(
        context,
        'Please enter all 6 digits of the OTP code',
      );
      return;
    }

    final email = _emailController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOtp(email, otp);

    if (!mounted) return;

    if (success) {
      setState(() => _currentStep = ForgotPasswordStep.newPassword);
    } else if (authProvider.errorMessage != null) {
      ErpToast.showError(
        context,
        authProvider.errorMessage!,
      );
    }
  }

  Future<void> _submitNewPassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final otp = _otpCode;
      final newPassword = _newPasswordController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(email, otp, newPassword);

      if (!mounted) return;

      if (success) {
        setState(() => _currentStep = ForgotPasswordStep.success);
        if (widget.onPasswordResetSuccess != null) {
          widget.onPasswordResetSuccess!(email);
        }
      } else if (authProvider.errorMessage != null) {
        ErpToast.showError(
          context,
          authProvider.errorMessage!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D44),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header indicator & title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Color(0xFF6C5CE7),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Stepper Indicator
              Row(
                children: [
                  _buildStepDot(0, 'Email', _currentStep.index >= 0),
                  _buildStepLine(_currentStep.index >= 1),
                  _buildStepDot(1, 'OTP', _currentStep.index >= 1),
                  _buildStepLine(_currentStep.index >= 2),
                  _buildStepDot(2, 'Reset', _currentStep.index >= 2),
                  _buildStepLine(_currentStep.index >= 3),
                  _buildStepDot(3, 'Done', _currentStep.index >= 3),
                ],
              ),
              const SizedBox(height: 28),

              // Step Content Switching
              if (_currentStep == ForgotPasswordStep.email) _buildEmailStep(authProvider),
              if (_currentStep == ForgotPasswordStep.otp) _buildOtpStep(authProvider),
              if (_currentStep == ForgotPasswordStep.newPassword) _buildNewPasswordStep(authProvider),
              if (_currentStep == ForgotPasswordStep.success) _buildSuccessStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(int index, String label, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFF1E1E2E),
            border: Border.all(
              color: isActive ? const Color(0xFF6C5CE7) : Colors.grey.shade700,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4).copyWith(bottom: 14),
        color: isActive ? const Color(0xFF6C5CE7) : Colors.grey.shade800,
      ),
    );
  }

  // --- Step 1: Email Form ---
  Widget _buildEmailStep(AuthProvider authProvider) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your registered email address',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C5CE7)),
              filled: true,
              fillColor: const Color(0xFF1E1E2E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _submitEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2: OTP Verification Form ---
  Widget _buildOtpStep(AuthProvider authProvider) {

    return Column(
      children: [
        Text(
          'Verification code sent to:',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text.trim(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 16),

        // OTP Banner Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.key_rounded, color: Color(0xFFA29BFE), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'OTP: ${authProvider.lastGeneratedOtp ?? '------'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (authProvider.lastGeneratedOtp != null) {
                    _autofillOtp(authProvider.lastGeneratedOtp!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Auto-fill',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 6 digit PIN input row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF1E1E2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (_otpCode.length == 6) {
                    _submitOtp();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Timer & Resend Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() => _currentStep = ForgotPasswordStep.email);
              },
              icon: const Icon(Icons.edit, size: 14, color: Colors.grey),
              label: const Text('Change email', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            TextButton(
              onPressed: _resendSeconds == 0 && !authProvider.isLoading ? _resendOtp : null,
              child: Text(
                _resendSeconds > 0 ? 'Resend code in ${_resendSeconds}s' : 'Resend Code',
                style: TextStyle(
                  color: _resendSeconds == 0 ? const Color(0xFF6C5CE7) : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _submitOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Verify OTP Code', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- Step 3: New Password Form ---
  Widget _buildNewPasswordStep(AuthProvider authProvider) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create your new password',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF6C5CE7)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
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
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF6C5CE7)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              filled: true,
              fillColor: const Color(0xFF1E1E2E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _submitNewPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 4: Success View ---
  Widget _buildSuccessStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Password Reset Complete!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been updated successfully. You can now login with your new credentials.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Login', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
