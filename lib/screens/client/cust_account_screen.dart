// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerAccount extends StatefulWidget {
  const CustomerAccount({super.key});

  @override
  State<CustomerAccount> createState() => _CustomerAccountState();
}

class _CustomerAccountState extends State<CustomerAccount> {
  Logger logger = Logger();

  String? name;
  String? email;
  String? phone;
  String? role;
  String? _profileImagePath;
  String? lastPassword;
  String? emailError;
  String? passwordError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadLastPassword();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await UserService().fetchLoggedInUser();
      setState(() {
        name = userData['name'];
        email = userData['email'];
        phone = userData['notelp'];
        role = userData['role'];
        _profileImagePath = userData['foto_profile'];
        _nameController.text = name ?? '';
        _emailController.text = email ?? '';
        _phoneController.text = phone ?? '';
      });
    } catch (e) {
      logger.i('Error fetching user data: $e');
      setState(() {
        name = ' ';
        email = ' ';
        phone = ' ';
        role = ' ';
      });
    }
  }

  Future<void> _loadLastPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final lp = prefs.getString('last_password');
    if (lp != null && lp.isNotEmpty) {
      setState(() {
        lastPassword = lp;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        emailError = '**Masukkan email yang valid (misal: user@gmail.com)';
        _isLoading = false;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => emailError = null);
      });
      return;
    }
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 8) {
      setState(() {
        passwordError = '**Password minimal 8 karakter';
        _isLoading = false;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => passwordError = null);
      });
      return;
    }
    try {
      await UserService().updateLoggedInUser({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'notelp': _phoneController.text.trim(),
        if (_passwordController.text.isNotEmpty)
          'password': _passwordController.text,
      });
      await _fetchUserData();
      setState(() {
        email = _emailController.text;
        phone = _phoneController.text;
        _isEditing = false;
      });
      CustomNotification.showSuccess(
        context: context,
        title: 'Berhasil diperbarui!',
        message: 'Profil Anda telah berhasil diperbarui',
      );
    } catch (e) {
      // Ganti SnackBar error dengan CustomNotification
      CustomNotification.showError(
        context: context,
        title: 'Gagal memperbarui!',
        message: 'Terjadi kesalahan saat memperbarui profil',
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleAppBar: 'Profil Saya',
        isIconShow: true,
        isLogoutIconShow: true,
        isNavigableByBottomBar: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildProfileImage(),
              const SizedBox(height: 16),
              Text(
                name ?? 'Loading...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role ?? 'Loading...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 40),
              _buildEditableField(
                label: "Username",
                controller: _nameController,
                icon: Icons.person,
                enabled: _isEditing,
                keyboardType: TextInputType.text,
                hintText: _isEditing ? "" : name ?? 'Tidak ada username',
              ),
              const SizedBox(height: 20),
              _buildEditableField(
                label: "Email Anda",
                controller: _emailController,
                icon: Icons.email,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                hintText: _isEditing ? "" : email ?? 'Tidak ada email',
              ),
              if (emailError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 12),
                    child: Text(
                      emailError!,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildEditableField(
                label: "No Handphone",
                controller: _phoneController,
                icon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                hintText:
                    _isEditing ? "" : phone ?? 'Tidak ada nomor handphone',
              ),
              const SizedBox(height: 20),
              _buildEditableField(
                label: "Password",
                controller: _passwordController,
                icon: Icons.lock,
                enabled: _isEditing,
                obscureText: true,
                hintText:
                    _isEditing
                        ? "Isi untuk ganti password"
                        : (lastPassword?.isNotEmpty == true
                            ? lastPassword
                            : "**********"),
              ),
              if (passwordError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 12),
                    child: Text(
                      passwordError!,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              _isEditing
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  'Simpan',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: semibold,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  setState(() {
                                    _isEditing = false;
                                    _emailController.text = email ?? '';
                                    _phoneController.text = phone ?? '';
                                    _passwordController.clear();
                                    emailError = null;
                                    passwordError = null;
                                  });
                                },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blueGrey.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            color: primaryColor,
                            fontWeight: semibold,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        'Edit Profil',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(currentPage: 'cust_account'),
    );
  }

  Widget _buildProfileImage() {
    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      return CircleAvatar(
        radius: 80,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: NetworkImage(_profileImagePath!),
      );
    } else {
      return ProfilePicture(name: name ?? '', radius: 80, fontsize: 48);
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = false,
    bool obscureText = false,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: semibold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 6, 32, 6),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50.withAlpha(120),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey.shade200.withAlpha(60)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blueGrey.shade600.withAlpha(120),
                size: 22,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText:
                      label == "Password" ? _obscurePassword : obscureText,
                  keyboardType: keyboardType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: medium,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: Colors.blueGrey.shade400,
                      fontWeight: medium,
                    ),
                    suffixIcon:
                        label == "Password"
                            ? _isEditing
                                ? IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.blueGrey.shade400,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                )
                                : null
                            : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
