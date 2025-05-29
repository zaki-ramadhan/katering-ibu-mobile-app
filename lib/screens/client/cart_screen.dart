import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/dummy_data.dart';
import 'package:katering_ibu_m_flutter/screens/client/rating_order_scren.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<int> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Keranjang Saya',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: Colors.white,
      body: SizedBox(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child: Column(
                children: [
                  _buildItem(context, 3),
                  _buildItem(context, 0),
                  _buildItem(context, 2),
                  _buildItem(context, 1),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCTABottomBar(context),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final isSelected = selectedItems.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedItems.remove(index);
          } else {
            selectedItems.add(index);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 16),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                DummyData.allMenus[index]['image'].toString(),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 18),
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DummyData.allMenus[index]['name'].toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: semibold,
                  ),
                ),
                Text(
                  DummyData.allMenus[index]['price'].toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: primaryColor.withAlpha(180),
                    fontSize: 16,
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryColor.withAlpha(60),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.remove),
                    padding: EdgeInsets.all(2),
                    style: IconButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                    ),
                  ),
                ),
                Text(
                  '1',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: semibold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  color: Colors.white,
                  padding: EdgeInsets.all(6),
                  style: IconButton.styleFrom(
                    backgroundColor: primaryColor,
                    splashFactory: InkRipple.splashFactory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTABottomBar(BuildContext context) {
    final allItemsSelected = selectedItems.length == DummyData.allMenus.length;
    final selectedCount =
        selectedItems.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (allItemsSelected) {
                      selectedItems.clear();
                    } else {
                      selectedItems.addAll(
                        List.generate(
                          DummyData.allMenus.length,
                          (index) => index,
                        ),
                      );
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      allItemsSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      allItemsSelected
                          ? 'Batalkan pilih semua menu'
                          : 'Pilih semua menu', 
                      style: GoogleFonts.plusJakartaSans(fontWeight: semibold),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: semibold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Item dipilih : ',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: '$selectedCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: extrabold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: semibold,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Rp210.000',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedItems.isEmpty
                      ? null
                      : () => Navigator.push(
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
                            return RatingOrderScren();
                          },
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                backgroundColor: primaryColor,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                splashFactory: InkRipple.splashFactory,
              ),
              child: Text(
                'Lanjut ke Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: semibold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
