import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/cart_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/cust_account_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/home_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/order_history_screen.dart';

class CustomBottomBar extends StatelessWidget {
  final String? currentPage;
  const CustomBottomBar({super.key, this.currentPage});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: white,
      height: 72,
      padding: EdgeInsetsDirectional.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildNavItem(
              currentPage == 'home' ? Icons.home : Icons.home_outlined,
              'Beranda',
              currentPage == 'home' ? true : false,
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
                    return FadeTransition(opacity: animation, child: child);
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return HomeScreen();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              currentPage == 'cart'
                  ? Icons.shopping_cart_rounded
                  : Icons.shopping_cart_outlined,
              'Keranjang',
              currentPage == 'cart' ? true : false,
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
                    return FadeTransition(opacity: animation, child: child);
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return CartScreen();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              currentPage == 'order_history' ? Icons.history : Icons.history,
              'Riwayat',
              currentPage == 'order_history' ? true : false,
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
                    return FadeTransition(opacity: animation, child: child);
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return OrderHistoryScreen();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              currentPage == 'cust_account' ? Icons.person : Icons.person,
              'Saya',
              currentPage == 'cust_account' ? true : false,
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
                    return FadeTransition(opacity: animation, child: child);
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return CustomerAccount();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? primaryColor : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? primaryColor : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: semibold,
            ),
          ),
        ],
      ),
    );
  }
}
