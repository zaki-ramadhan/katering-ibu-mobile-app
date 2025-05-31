// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/login_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/index.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
      var url = Uri.parse('$baseUrl/register');
      try {
        var response = await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': _fullNameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'password_confirmation': _passwordController.text.trim(),
          }),
        );

        final data = json.decode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'last_password',
            _passwordController.text.trim(),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pendaftaran berhasil!',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.green,
            ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Pendaftaran gagal. Terjadi kesalahan.',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pendaftaran gagal. Periksa koneksi internet Anda.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red,
          ),
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
                RichText(
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
                        text: 'Nama Lengkap',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: medium,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fullNameController,
                  focusNode: _fullNameFocusNode,
                  decoration: InputDecoration(
                    hintText: _fullNameFocusNode.hasFocus ? '' : 'John Doe',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _fullNameError.isNotEmpty
                                ? Colors.red
                                : transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _fullNameError.isNotEmpty
                                ? Colors.red
                                : primaryColor,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                if (_fullNameError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _fullNameError,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                RichText(
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
                        text: 'Email',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: medium,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(
                    hintText:
                        _emailFocusNode.hasFocus ? '' : 'johndoe@gmail.com',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _emailError.isNotEmpty ? Colors.red : transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _emailError.isNotEmpty ? Colors.red : primaryColor,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                if (_emailError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _emailError,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                RichText(
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
                        text: 'Password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: medium,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _showPassword,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    hintText: _passwordFocusNode.hasFocus ? '' : '• • • • • •',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _passwordError.isNotEmpty
                                ? Colors.red
                                : transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _passwordError.isNotEmpty
                                ? Colors.red
                                : primaryColor,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                if (_passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _passwordError,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
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
                            () => Navigator.push(
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
      ),
    );
  }
}
