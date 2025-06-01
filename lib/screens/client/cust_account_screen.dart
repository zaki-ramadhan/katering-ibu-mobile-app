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

    bool shouldSave = await _showSaveConfirmationDialog();
    if (!shouldSave) return;

    _showSaveLoadingDialog();

    try {
      await UserService().updateLoggedInUser({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'notelp': _phoneController.text.trim(),
        if (_passwordController.text.isNotEmpty)
          'password': _passwordController.text,
      });

      Navigator.pop(context);

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
      Navigator.pop(context);

      CustomNotification.showError(
        context: context,
        title: 'Gagal memperbarui!',
        message: 'Terjadi kesalahan saat memperbarui profil',
      );
    }
  }

  Future<bool> _showSaveConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, primaryColor],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.save_alt_rounded,
                        color: white,
                        size: 45,
                      ),
                    ),
                    SizedBox(height: 28),
                    Text(
                      'Simpan Perubahan?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Data yang akan diperbarui:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _buildChangeItem(
                            'Username',
                            name ?? '',
                            _nameController.text,
                          ),
                          SizedBox(height: 12),
                          _buildChangeItem(
                            'Email',
                            email ?? '',
                            _emailController.text,
                          ),
                          SizedBox(height: 12),
                          _buildChangeItem(
                            'No. Handphone',
                            phone ?? '',
                            _phoneController.text,
                          ),
                          if (_passwordController.text.isNotEmpty)
                            _buildChangeItem(
                              'Password',
                              '••••••••',
                              'Password baru',
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_passwordController.text.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Password akan diubah, pastikan Anda mengingat password baru',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: white,
                                elevation: 0,
                                shadowColor: transparent,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Simpan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _showSaveLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      ),
                      Icon(Icons.person_outline, color: primaryColor, size: 24),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Menyimpan Profil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Mohon tunggu sebentar...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangeItem(String label, String oldValue, String newValue) {
    bool hasChanged = oldValue != newValue;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  hasChanged ? Colors.orange.shade500 : Colors.green.shade500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (hasChanged) ...[
                  Text(
                    oldValue.isEmpty ? '(kosong)' : oldValue,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.red.shade600,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    newValue,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Tidak ada perubahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
                      style: TextStyle(color: errorColor, fontSize: 13),
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
                      style: TextStyle(color: errorColor, fontSize: 13),
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
                                    color: white,
                                  ),
                                )
                                : Text(
                                  'Simpan',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: white,
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
                          color: white,
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
