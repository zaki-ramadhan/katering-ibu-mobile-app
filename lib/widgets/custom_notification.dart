import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/index.dart';

class CustomNotification {
  static void show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Hide current snackbar jika ada
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: semibold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withAlpha(229),
                        fontSize: 12,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Predefined methods untuk kemudahan
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      icon: Icons.check_circle_outline,
      title: title,
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(message, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      icon: Icons.info_outline,
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      icon: Icons.warning_amber_outlined,
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  static void showCart({
    required BuildContext context,
    required String menuName,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context: context,
      icon: Icons.shopping_cart,
      title: 'Ditambahkan ke keranjang!',
      message: 'Menu $menuName berhasil ditambahkan',
      backgroundColor: Colors.green,
      duration: duration,
    );
  }
}
