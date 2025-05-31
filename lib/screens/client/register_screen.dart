// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/screens/client/login_screen.dart';
import 'package:katering_ibu_m_flutter/services/auth_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import '../../constants/index.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String _fullNameError = '';
  String _emailError = '';
  String _passwordError = '';
  bool _showPassword = true;

  @override
  void initState() {
    super.initState();

    _fullNameController.addListener(_clearFullNameError);
    _emailController.addListener(_clearEmailError);
    _passwordController.addListener(_clearPasswordError);

    _fullNameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));

    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _clearFullNameError() {
    if (_fullNameError.isNotEmpty) {
      setState(() {
        _fullNameError = '';
      });
    }
  }

  void _clearEmailError() {
    if (_emailError.isNotEmpty) {
      setState(() {
        _emailError = '';
      });
    }
  }

  void _clearPasswordError() {
    if (_passwordError.isNotEmpty) {
      setState(() {
        _passwordError = '';
      });
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _fullNameError =
          _fullNameController.text.trim().isEmpty
              ? 'Nama lengkap wajib diisi'
              : '';
      _emailError =
          _emailController.text.trim().isEmpty ? 'Email wajib diisi' : '';
      _passwordError =
          _passwordController.text.trim().isEmpty ? 'Password wajib diisi' : '';
    });

    if (_fullNameError.isEmpty &&
        _emailError.isEmpty &&
        _passwordError.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      final result = await AuthService.register(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        CustomNotification.showSuccess(
          context: context,
          title: 'Pendaftaran Berhasil',
          message: result['message'],
          duration: Duration(seconds: 2),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        });
      } else {
        CustomNotification.showError(
          context: context,
          title: 'Pendaftaran Gagal',
          message: result['message'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Katering Ibu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Belanja katering anti ribet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                Text(
                  'Buat Akun Anda.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Daftarkan diri Anda untuk mulai menikmati layanan katering praktis dan tanpa ribet.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                _buildLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextField(
                  controller: _fullNameController,
                  focusNode: _fullNameFocusNode,
                  enabled: !_isLoading,
                  decoration: _inputDecoration(
                    hint: _fullNameFocusNode.hasFocus ? '' : 'John Doe',
                    errorText: _fullNameError,
                  ),
                ),
                if (_fullNameError.isNotEmpty) _buildErrorText(_fullNameError),
                const SizedBox(height: 30),

                _buildLabel('Email'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  enabled: !_isLoading,
                  decoration: _inputDecoration(
                    hint: _emailFocusNode.hasFocus ? '' : 'johndoe@gmail.com',
                    errorText: _emailError,
                  ),
                ),
                if (_emailError.isNotEmpty) _buildErrorText(_emailError),
                const SizedBox(height: 30),

                _buildLabel('Password'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _showPassword,
                  focusNode: _passwordFocusNode,
                  enabled: !_isLoading,
                  decoration: _inputDecoration(
                    hint: _passwordFocusNode.hasFocus ? '' : '• • • • • •',
                    errorText: _passwordError,
                  ).copyWith(
                    suffixIcon:
                        _passwordController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            )
                            : null,
                  ),
                ),
                if (_passwordError.isNotEmpty) _buildErrorText(_passwordError),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: primaryColor.withOpacity(0.6),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Buat Akun',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: medium,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 36),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 4.0),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed:
                            _isLoading
                                ? null
                                : () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    pageBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                    ) {
                                      return const LoginScreen();
                                    },
                                  ),
                                ),
                        child: Text(
                          'Masuk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: _isLoading ? Colors.grey : primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '* ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          TextSpan(
            text: text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: medium,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required String errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      filled: true,
      fillColor: Colors.grey[100],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText.isNotEmpty ? Colors.red : transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText.isNotEmpty ? Colors.red : primaryColor,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        error,
        style: GoogleFonts.plusJakartaSans(color: Colors.red, fontSize: 14),
      ),
    );
  }
}
