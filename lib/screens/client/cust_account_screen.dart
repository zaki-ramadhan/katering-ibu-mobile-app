import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:logger/logger.dart';

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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
        _emailController.text = email ?? '';
        _phoneController.text = phone ?? '';
      });
    } catch (e) {
      logger.i('Error fetching user data: $e');
      setState(() {
        name = 'Error';
        email = 'Error';
        phone = 'Error';
        role = 'Error';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email tidak valid')));
      setState(() => _isLoading = false);
      return;
    }
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Handphone tidak boleh kosong')),
      );
      setState(() => _isLoading = false);
      return;
    }
    try {
      await UserService().updateLoggedInUser({
        'email': _emailController.text.trim(),
        'notelp': _phoneController.text.trim(),
        if (_passwordController.text.isNotEmpty)
          'password': _passwordController.text,
      });
      setState(() {
        email = _emailController.text;
        phone = _phoneController.text;
        _isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update profil')));
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
                label: "Email Anda",
                controller: _emailController,
                icon: Icons.email,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildEditableField(
                label: "No Handphone",
                controller: _phoneController,
                icon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildEditableField(
                label: "Password",
                controller: _passwordController,
                icon: Icons.lock,
                enabled: _isEditing,
                obscureText: true,
                hintText:
                    _isEditing ? "Isi untuk ganti password" : "**********",
              ),
              const SizedBox(height: 32),
              _isEditing
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                  });
                                },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Center(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Edit Profil',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
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
          padding: const EdgeInsets.fromLTRB(24, 0, 32, 0),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50.withAlpha(120),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blueGrey.shade600.withAlpha(120),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: medium,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
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
