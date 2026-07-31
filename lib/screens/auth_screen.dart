import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = Provider.of<DemoProvider>(context, listen: false);

    try {
      if (_isLogin) {
        final error = await provider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        if (error != null) {
          _showError(error);
        } else {
          _navigateAfterAuth();
        }
      } else {
        final error = await provider.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        if (error != null) {
          _showError(error);
        } else {
          _navigateAfterAuth();
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).error);
    }
  }

  void _navigateAfterAuth() {
    final provider = Provider.of<DemoProvider>(context, listen: false);
    if (provider.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showResetPasswordDialog() {
    final loc = AppLocalizations.of(context);
    final emailController = TextEditingController();
    final codeController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    String? generatedCode;
    bool codeSent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.resetPassword),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.resetPasswordHint, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: loc.email,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                if (codeSent) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.verificationCode}: $generatedCode',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: loc.verificationCode,
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.pin),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: newPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: loc.newPassword,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: confirmPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: loc.confirmNewPassword,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (!codeSent) {
                  if (emailController.text.isEmpty || !emailController.text.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.enterValidEmail), backgroundColor: Colors.orange),
                    );
                    return;
                  }
                  final provider = Provider.of<DemoProvider>(context, listen: false);
                  final exists = await provider.userExists(emailController.text.trim());
                  if (!exists) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.emailNotFound), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  generatedCode = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
                  setDialogState(() => codeSent = true);
                  return;
                }
                if (codeController.text != generatedCode) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.invalidCode), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (newPassController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.passwordTooShort), backgroundColor: Colors.orange),
                  );
                  return;
                }
                if (newPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.passwordMismatch), backgroundColor: Colors.orange),
                  );
                  return;
                }
                final provider = Provider.of<DemoProvider>(context, listen: false);
                final error = await provider.resetPassword(emailController.text.trim(), newPassController.text);
                if (!context.mounted) return;
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.resetPasswordSuccess), backgroundColor: Colors.green),
                  );
                }
              },
              child: Text(codeSent ? loc.reset : loc.send),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    ).then((_) {
      emailController.dispose();
      codeController.dispose();
      newPassController.dispose();
      confirmPassController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.pets, size: 50, color: Colors.white),
                ),
                SizedBox(height: 16),
                  Text(
                    loc.appName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _isLogin ? loc.login : loc.createAccount,
                  style: TextStyle(fontSize: 16, color: Colors.white54),
                ),
                SizedBox(height: 32),
                GlassContainer(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          _buildTextField(
                            controller: _nameController,
                            label: loc.name,
                            icon: Icons.person,
                            validator: (v) => v == null || v.isEmpty ? loc.enterName : null,
                          ),
                          SizedBox(height: 16),
                        ],
                        _buildTextField(
                          controller: _emailController,
                          label: loc.email,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.enterEmail;
                            if (!v.contains('@')) return loc.invalidEmail;
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: loc.password,
                          icon: Icons.lock,
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.enterPassword;
                            if (v.length < 6) return loc.passwordHint;
                            return null;
                          },
                        ),
                        if (!_isLogin) ...[
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: loc.confirmPassword,
                            icon: Icons.lock_outline,
                            obscure: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return loc.enterPassword;
                              if (v != _passwordController.text) return loc.passwordMismatch;
                              return null;
                            },
                          ),
                        ],
                        if (_isLogin)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => _showResetPasswordDialog(),
                              child: Text(loc.forgotPassword, style: TextStyle(color: AppColors.gold, fontSize: 13)),
                            ),
                          ),
                        SizedBox(height: 24),
                        Consumer<DemoProvider>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: GradientButton(
                                onTap: provider.isLoading ? null : _submit,
                                gradient: AppColors.primaryGradient,
                                child: Center(
                                  child: provider.isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : Text(
                                          _isLogin ? loc.login : loc.createAccount,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            _isLogin ? loc.noAccount : loc.hasAccount,
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/privacy'),
                      child: Text(loc.privacyPolicy, style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white38)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/terms'),
                      child: Text(loc.termsOfService, style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.purpleLight),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}
