// ignore_for_file: use_build_context_synchronously

import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:katering_ibu_m_flutter/screens/client/home_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/index.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Logger logger = Logger();
  bool _rememberMe = false;

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('user_id');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (token != null && userId != null && rememberMe) {
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
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
      } else if (!rememberMe) {
        await prefs.remove('token');
        await prefs.remove('user_id');
        await prefs.remove('user_name');
        await prefs.remove('user_role');
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }
    } catch (e) {
      var logger = Logger();
      logger.d('Error checking login status: $e');
    }
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
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          },
        );

        final response = await http.post(
          Uri.parse('$localHost/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'username': _usernameController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        Navigator.pop(context);

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          logger.i('Token saved: ${data['token']}');
          await prefs.setInt('user_id', data['user']['id']);
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString('user_role', data['user']['role']);

          await prefs.setBool('remember_me', _rememberMe);
          if (_rememberMe) {
            await prefs.setString(
              'saved_username',
              _usernameController.text.trim(),
            );
            await prefs.setString(
              'saved_password',
              _passwordController.text.trim(),
            );
          } else {
            await prefs.remove('saved_username');
            await prefs.remove('saved_password');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Selamat datang, ${data['user']['name']}!',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        HomeScreen(),
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
          _showErrorDialog(data['message'] ?? 'Terjadi kesalahan');
        }
      } catch (e) {
        logger.e('Login error: $e');
        _showErrorDialog('Terjadi kesalahan koneksi');
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('saved_username') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Gagal Login',
              style: GoogleFonts.plusJakartaSans(fontWeight: semibold),
            ),
            content: Text(message, style: GoogleFonts.plusJakartaSans()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.plusJakartaSans(
                    color: primaryColor,
                    fontWeight: semibold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    onChanged: (bool? value) {
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
                      fontWeight: medium
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Masuk',
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
                          () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 300),
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
                                return SignUpScreen();
                              },
                            ),
                          ),
                      child: Text(
                        'Daftar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: primaryColor,
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
              color: Colors.red,
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
