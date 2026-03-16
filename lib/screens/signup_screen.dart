import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'signin_screen.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthService>();
    final error = await auth.signInWithGoogle();
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      _goHome();
    } else if (error != 'cancelled') {
      _showError('สมัครด้วย Google ไม่สำเร็จ กรุณาลองอีกครั้ง');
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showError('กรุณายอมรับข้อกำหนดการใช้งาน');
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthService>();
    final error = await auth.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      _goHome();
    } else {
      _showError(error);
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                padding: EdgeInsets.zero,
                color: AppColors.textPrimary,
              ),

              const SizedBox(height: 28),

              _buildHeader(),

              const SizedBox(height: 32),

              // Google Sign Up
              _buildGoogleButton(),

              const SizedBox(height: 22),

              _buildDivider(),

              const SizedBox(height: 22),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: 'ชื่อของคุณ',
                      icon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'กรุณากรอกชื่อ';
                        if (val.length < 2) return 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: 'อีเมล',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'กรุณากรอกอีเมล';
                        if (!val.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      controller: _passwordCtrl,
                      hint: 'รหัสผ่าน',
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'กรุณากรอกรหัสผ่าน';
                        if (val.length < 6)
                          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      controller: _confirmCtrl,
                      hint: 'ยืนยันรหัสผ่าน',
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'กรุณายืนยันรหัสผ่าน';
                        if (val != _passwordCtrl.text)
                          return 'รหัสผ่านไม่ตรงกัน';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Terms checkbox
              _buildTermsCheckbox(),

              const SizedBox(height: 24),

              // Sign Up button
              _buildSignUpButton(),

              const SizedBox(height: 28),

              // Sign In link
              _buildSignInLink(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_stories_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        const Text(
          'สร้างบัญชีใหม่',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'เริ่มต้นการเดินทางแห่งการอ่านกับเรา',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signUpWithGoogle,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.grey.shade300),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Google icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                ),
              ),
              child: const Icon(Icons.g_mobiledata,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            const Text(
              'สมัครด้วย Google',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'หรือสมัครด้วยอีเมล',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppColors.textHint, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Poppins'),
                children: [
                  TextSpan(text: 'ฉันยอมรับ '),
                  TextSpan(
                    text: 'ข้อกำหนดการใช้งาน',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: ' และ '),
                  TextSpan(
                    text: 'นโยบายความเป็นส่วนตัว',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.35),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'สมัครสมาชิก',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'มีบัญชีอยู่แล้ว? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          ),
          child: const Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
        ),
      ],
    );
  }
}
