// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/screens/client/home_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/register_screen.dart';
import 'package:katering_ibu_m_flutter/services/auth_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import '../../constants/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String _usernameError = '';
  String _passwordError = '';
  bool _showPassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadSavedCredentials();
    _usernameController.addListener(_clearUsernameError);
    _passwordController.addListener(_clearPasswordError);

    _passwordController.addListener(() {
      setState(() {});
    });

    _usernameFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _clearUsernameError() {
    if (_usernameError.isNotEmpty) {
      setState(() {
        _usernameError = '';
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

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.checkLoginStatus();
    if (isLoggedIn) {
      _navigateToHome();
    }
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await AuthService.getSavedCredentials();
    setState(() {
      _rememberMe = credentials['remember_me'] == 'true';
      if (_rememberMe) {
        _usernameController.text = credentials['username'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
      }
    });
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _usernameError =
          _usernameController.text.trim().isEmpty ? 'Username wajib diisi' : '';
      _passwordError =
          _passwordController.text.trim().isEmpty ? 'Password wajib diisi' : '';
    });

    if (_usernameError.isEmpty && _passwordError.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      final result = await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        rememberMe: _rememberMe,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        CustomNotification.showSuccess(
          context: context,
          title: 'Login Berhasil',
          message: 'Selamat datang, ${result['user']['name']}!',
          duration: Duration(seconds: 2),
        );

        Future.delayed(const Duration(seconds: 2), () {
          _navigateToHome();
        });
      } else {
        CustomNotification.showError(
          context: context,
          title: 'Login Gagal',
          message: result['message'],
        );
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder:
            (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
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
                'Masuk ke Akun Anda.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Masukkan informasi akun Anda untuk mengakses layanan Katering Ibu dengan mudah dan cepat.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel('Username'),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                enabled: !_isLoading,
                decoration: _inputDecoration(
                  hint: _usernameFocusNode.hasFocus ? '' : 'JohnDoe123',
                  errorText: _usernameError,
                ),
              ),
              if (_usernameError.isNotEmpty) _buildErrorText(_usernameError),
              const SizedBox(height: 20),

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
              const SizedBox(height: 10),

              if (_passwordError.isNotEmpty) _buildErrorText(_passwordError),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: primaryColor,
                    onChanged:
                        _isLoading
                            ? null
                            : (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                  ),
                  Text(
                    'Ingat Saya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
                    disabledBackgroundColor: primaryColor..withAlpha(153),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(white),
                            ),
                          )
                          : Text(
                            'Masuk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: medium,
                              color: white,
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
                      'Belum punya akun? ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 0),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 4.0),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration(
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
                                    return Register();
                                  },
                                ),
                              ),
                      child: Text(
                        'Daftar',
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
              color: errorColor,
            ),
          ),
          TextSpan(
            text: text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: medium,
              color: Colors.black,
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
          color: errorText.isNotEmpty ? errorColor : transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText.isNotEmpty ? errorColor : primaryColor,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2.0),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        error,
        style: GoogleFonts.plusJakartaSans(color: errorColor, fontSize: 14),
      ),
    );
  }
}
