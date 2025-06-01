// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/provider/cart_provider.dart';

import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/models/user_model.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutOrderScreen extends StatefulWidget {
  final List<CartItem>? selectedItems;

  const CheckoutOrderScreen({super.key, this.selectedItems});

  @override
  State<CheckoutOrderScreen> createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  bool _isShowed = false;
  String _selectedPickupMethod = 'pickup';
  String _selectedPaymentMethod = 'cash';
  String _selectedTransferMethod = 'bri';
  Logger logger = Logger();

  final double _deliveryFee = 15000;
  final NumberFormat rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoadingUser = true;

  final TextEditingController _alamatController = TextEditingController();
  final FocusNode _alamatFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isAlamatFocused = false;

  List<CartItem> _checkoutItems = [];
  double _checkoutTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeCheckoutItems();

    _alamatFocusNode.addListener(() {
      setState(() {
        _isAlamatFocused = _alamatFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _alamatFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.fetchLoggedInUser();
      setState(() {
        _currentUser = User.fromJson(userData);
        _isLoadingUser = false;
      });
    } catch (e) {
      logger.e('Error loading user: $e');
      await _loadUserFromPrefs();
    }
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      final userId = prefs.getInt('user_id');

      setState(() {
        if (userName != null && userId != null) {
          _currentUser = User(
            id: userId,
            nama: userName,
            email: 'email@example.com',
            phone: 'Nomor HP tidak tersedia',
          );
        }
        _isLoadingUser = false;
      });
    } catch (e) {
      logger.e('Error loading user from prefs: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _initializeCheckoutItems() {
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      _checkoutItems = widget.selectedItems!;
    } else {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      _checkoutItems = cartProvider.cartItems;
    }

    _checkoutTotal = _checkoutItems.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Checkout Pesanan',
        isIconShow: false,
        isLogoutIconShow: false,
      ),
      backgroundColor: white,
      body:
          _isLoadingUser
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Column(
                      spacing: 40,
                      children: [
                        _buildCustomerInfo(),
                        _buildOrderItems(),
                        _buildPickupMethod(),
                        if (_selectedPickupMethod == 'delivery')
                          _buildDeliveryAddress(),
                        _buildPaymentMethod(),
                      ],
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          'Informasi Pemesan:',
          style: GoogleFonts.plusJakartaSans(fontWeight: medium, fontSize: 18),
        ),
        _buildDisplayInput(
          defaultVal: _currentUser?.nama ?? 'Nama Pengguna',
          icon: Icons.person,
          size: 28,
        ),
        _buildDisplayInput(
          defaultVal: _currentUser?.email ?? 'email@example.com',
          icon: Icons.email_rounded,
          size: 24,
        ),
        _buildDisplayInput(
          defaultVal: _currentUser?.phone ?? 'Nomor HP',
          icon: Icons.phone,
          size: 26,
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black),
            children: [
              TextSpan(
                text: '** ',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: medium,
                  fontSize: 14,
                  color: Colors.red.shade300,
                ),
              ),
              TextSpan(
                text:
                    'Informasi diambil dari data profil akun Anda. '
                    'Untuk mengubah, silakan perbarui profil terlebih dahulu.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: medium,
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          'Metode Pengambilan:',
          style: GoogleFonts.plusJakartaSans(fontWeight: medium, fontSize: 18),
        ),

        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPickupMethod = 'pickup';
              _alamatController.clear();
            });
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedPickupMethod == 'pickup'
                        ? primaryColor
                        : Colors.grey.shade300,
                width: _selectedPickupMethod == 'pickup' ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color:
                  _selectedPickupMethod == 'pickup'
                      ? primaryColor.withAlpha(15)
                      : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store,
                  color:
                      _selectedPickupMethod == 'pickup'
                          ? primaryColor
                          : Colors.grey.shade600,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambil Sendiri',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: semibold,
                          fontSize: 15,
                          color:
                              _selectedPickupMethod == 'pickup'
                                  ? primaryColor
                                  : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Datang langsung ke lokasi Katering Ibu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gratis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _selectedPickupMethod == 'pickup'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color:
                      _selectedPickupMethod == 'pickup'
                          ? primaryColor
                          : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPickupMethod = 'delivery';
            });
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedPickupMethod == 'delivery'
                        ? primaryColor
                        : Colors.grey.shade300,
                width: _selectedPickupMethod == 'delivery' ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color:
                  _selectedPickupMethod == 'delivery'
                      ? primaryColor.withAlpha(15)
                      : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delivery_dining,
                  color:
                      _selectedPickupMethod == 'delivery'
                          ? primaryColor
                          : Colors.grey.shade600,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Antar ke Alamat',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: semibold,
                          fontSize: 15,
                          color:
                              _selectedPickupMethod == 'delivery'
                                  ? primaryColor
                                  : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pesanan akan diantar ke alamat yang Anda tentukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        rupiahFormat.format(_deliveryFee),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _selectedPickupMethod == 'delivery'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color:
                      _selectedPickupMethod == 'delivery'
                          ? primaryColor
                          : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          'Alamat Pengiriman:',
          style: GoogleFonts.plusJakartaSans(fontWeight: medium, fontSize: 18),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isAlamatFocused ? primaryColor : Colors.grey.shade300,
              width: _isAlamatFocused ? 2 : 1,
            ),
            color:
                _isAlamatFocused
                    ? primaryColor.withAlpha(10)
                    : Colors.transparent,
          ),
          child: TextFormField(
            controller: _alamatController,
            focusNode: _alamatFocusNode,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Masukkan alamat lengkap untuk pengiriman...\n\nContoh: Jl. Merdeka No. 123, RT 01/RW 02, Kelurahan ABC, Kecamatan XYZ',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Container(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.location_on,
                  color: _isAlamatFocused ? primaryColor : Colors.grey.shade600,
                  size: 26,
                ),
              ),
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: Colors.black87,
            ),
            validator: (value) {
              if (_selectedPickupMethod == 'delivery' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Alamat pengiriman harus diisi';
              }
              if (_selectedPickupMethod == 'delivery' &&
                  value!.trim().length < 10) {
                return 'Alamat terlalu pendek, masukkan alamat lengkap';
              }
              return null;
            },
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black),
            children: [
              TextSpan(
                text: '** ',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: medium,
                  fontSize: 14,
                  color: Colors.orange.shade300,
                ),
              ),
              TextSpan(
                text:
                    'Pastikan alamat sudah benar dan lengkap. Kurir akan menghubungi Anda jika alamat sulit ditemukan.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: medium,
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          'Metode Pembayaran:',
          style: GoogleFonts.plusJakartaSans(fontWeight: medium, fontSize: 18),
        ),

        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'cash';
            });
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedPaymentMethod == 'cash'
                        ? primaryColor
                        : Colors.grey.shade300,
                width: _selectedPaymentMethod == 'cash' ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color:
                  _selectedPaymentMethod == 'cash'
                      ? primaryColor.withAlpha(15)
                      : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.money,
                  color:
                      _selectedPaymentMethod == 'cash'
                          ? primaryColor
                          : Colors.grey.shade600,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tunai (Cash)',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: semibold,
                          fontSize: 15,
                          color:
                              _selectedPaymentMethod == 'cash'
                                  ? primaryColor
                                  : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bayar langsung saat pengambilan/pengantaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _selectedPaymentMethod == 'cash'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color:
                      _selectedPaymentMethod == 'cash'
                          ? primaryColor
                          : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'cashless';
            });
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedPaymentMethod == 'cashless'
                        ? primaryColor
                        : Colors.grey.shade300,
                width: _selectedPaymentMethod == 'cashless' ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color:
                  _selectedPaymentMethod == 'cashless'
                      ? primaryColor.withAlpha(15)
                      : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color:
                      _selectedPaymentMethod == 'cashless'
                          ? primaryColor
                          : Colors.grey.shade600,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transfer/E-Wallet',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: semibold,
                          fontSize: 15,
                          color:
                              _selectedPaymentMethod == 'cashless'
                                  ? primaryColor
                                  : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Transfer bank atau pembayaran digital',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _selectedPaymentMethod == 'cashless'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color:
                      _selectedPaymentMethod == 'cashless'
                          ? primaryColor
                          : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),

        if (_selectedPaymentMethod == 'cashless') _buildTransferOptions(),
      ],
    );
  }

  Widget _buildDisplayInput({
    required String defaultVal,
    required IconData icon,
    required double size,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: size, color: primaryColor.withAlpha(80)),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              defaultVal,
              style: GoogleFonts.plusJakartaSans(
                color: primaryColor,
                fontWeight: medium,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final subtotal = _checkoutTotal;
    final deliveryFee = _selectedPickupMethod == 'delivery' ? _deliveryFee : 0;
    final total = subtotal + deliveryFee;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 4, 0, 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_isShowed ? 44 : 32),
          topRight: Radius.circular(_isShowed ? 44 : 32),
        ),
      ),
      child: Column(
        spacing: _isShowed ? 14 : 2,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isShowed = !_isShowed;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total (${_checkoutItems.length} item):',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: white.withAlpha(200),
                                fontWeight: medium,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              rupiahFormat.format(total),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: semibold,
                                color: white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 12),
                          child: Icon(
                            _isShowed
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isShowed)
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      spacing: 12,
                      children: [
                        ...(_checkoutItems.map(
                          (item) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.menu.namaMenu}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: white.withAlpha(140),
                                    fontWeight: medium,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                rupiahFormat.format(item.totalPrice),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: medium,
                                  color: white.withAlpha(140),
                                ),
                              ),
                            ],
                          ),
                        )),
                        Divider(color: white.withAlpha(100), height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal :',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: white.withAlpha(140),
                                fontWeight: medium,
                              ),
                            ),
                            Text(
                              rupiahFormat.format(subtotal),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: medium,
                                color: white.withAlpha(140),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedPickupMethod == 'delivery')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biaya Ongkir :',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: white.withAlpha(140),
                                  fontWeight: medium,
                                ),
                              ),
                              Text(
                                rupiahFormat.format(deliveryFee),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: medium,
                                  color: white.withAlpha(140),
                                ),
                              ),
                            ],
                          ),
                        if (_selectedPickupMethod == 'pickup')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ongkir :',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: white.withAlpha(140),
                                  fontWeight: medium,
                                ),
                              ),
                              Text(
                                'Gratis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: semibold,
                                  color: Colors.green.shade200,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 20),
            child: ElevatedButton(
              onPressed: () {
                _processCheckout(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: white,
                elevation: 0,
                shadowColor: transparent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Buat Pesanan (${_checkoutItems.length} item)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: semibold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context) async {
    if (_selectedPickupMethod == 'delivery') {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon lengkapi alamat pengiriman'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Memproses ${_checkoutItems.length} item...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    List<Menu> menusToRemove = _checkoutItems.map((item) => item.menu).toList();
    await cartProvider.removeMultipleItems(menusToRemove);

    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pesanan ${_checkoutItems.length} item berhasil dibuat!',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTransferOptions() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'Pilih Metode Transfer:',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: semibold,
              fontSize: 16,
              color: primaryColor,
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTransferMethod = 'bri';
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _selectedTransferMethod == 'bri'
                          ? primaryColor
                          : Colors.grey.shade300,
                  width: _selectedTransferMethod == 'bri' ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color:
                    _selectedTransferMethod == 'bri'
                        ? primaryColor.withAlpha(20)
                        : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color:
                        _selectedTransferMethod == 'bri'
                            ? primaryColor
                            : Colors.grey.shade600,
                    size: 22,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'Transfer Bank BRI',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: semibold,
                            fontSize: 15,
                            color:
                                _selectedTransferMethod == 'bri'
                                    ? primaryColor
                                    : Colors.black87,
                          ),
                        ),
                        Text(
                          'No. Rek: 4194 0103 9789 537',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: medium,
                          ),
                        ),
                        Text(
                          'a.n. Fiqry Omar Atala',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedTransferMethod == 'bri'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        _selectedTransferMethod == 'bri'
                            ? primaryColor
                            : Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTransferMethod = 'dana';
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _selectedTransferMethod == 'dana'
                          ? primaryColor
                          : Colors.grey.shade300,
                  width: _selectedTransferMethod == 'dana' ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color:
                    _selectedTransferMethod == 'dana'
                        ? primaryColor.withAlpha(20)
                        : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wallet,
                    color:
                        _selectedTransferMethod == 'dana'
                            ? primaryColor
                            : Colors.grey.shade600,
                    size: 22,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'DANA E-Wallet',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: semibold,
                            fontSize: 15,
                            color:
                                _selectedTransferMethod == 'dana'
                                    ? primaryColor
                                    : Colors.black87,
                          ),
                        ),
                        Text(
                          'No. DANA: +62 812-3456-7890',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: medium,
                          ),
                        ),
                        Text(
                          'a.n. Sausan Ronna Ullaya',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedTransferMethod == 'dana'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        _selectedTransferMethod == 'dana'
                            ? primaryColor
                            : Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withAlpha(160),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Setelah transfer, mohon kirim bukti pembayaran melalui WhatsApp atau upload di aplikasi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          'Menu yang dipesan:',
          style: GoogleFonts.plusJakartaSans(fontWeight: medium, fontSize: 18),
        ),

        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _checkoutItems.length,
            separatorBuilder: (context, index) => SizedBox(width: 4),
            itemBuilder: (context, index) {
              final item = _checkoutItems[index];
              return SizedBox(
                width: 80,
                child: Column(
                  spacing: 8,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        image:
                            item.menu.foto.isNotEmpty
                                ? DecorationImage(
                                  image: NetworkImage(item.menu.foto),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          item.menu.foto.isEmpty
                              ? Icon(
                                Icons.restaurant,
                                color: Colors.grey.shade400,
                                size: 30,
                              )
                              : null,
                    ),
                    Text(
                      '${item.quantity}x',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: semibold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
