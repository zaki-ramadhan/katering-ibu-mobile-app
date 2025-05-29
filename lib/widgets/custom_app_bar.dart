import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/login_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/notification_screen.dart';
import 'package:katering_ibu_m_flutter/widgets/logout_confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;
  final bool isIconShow;
  final bool isLogoutIconShow;
  final bool isNavigableByBottomBar;
  const CustomAppBar({
    super.key,
    required this.titleAppBar,
    required this.isLogoutIconShow,
    required this.isIconShow,
    this.isNavigableByBottomBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 1,
      surfaceTintColor: transparent,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.navigate_before,
          color: Colors.black54,
          size: 32,
        ),
        onPressed:
            () =>
                isNavigableByBottomBar == false
                    ? Navigator.pop(context)
                    : Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      title: Text(
        titleAppBar,
        style: GoogleFonts.plusJakartaSans(
          color: primaryColor,
          fontSize: 18,
          fontWeight: medium,
        ),
      ),
      actions: [
        !isIconShow
            ? const SizedBox()
            : !isLogoutIconShow
            ? IconButton(
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
                        return FadeTransition(opacity: animation, child: child);
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return NotificationScreen();
                      },
                    ),
                  ),
              icon: Icon(Icons.notifications_outlined),
              iconSize: 26,
              color: primaryColor.withAlpha(160),
            )
            :
            IconButton(
              icon: Icon(Icons.logout_rounded, color: primaryColor),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return LogoutConfirmationDialog(
                      onConfirm: () async {
                        try {
                          final prefs = await SharedPreferences.getInstance();

                          await prefs.clear();

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
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
                                  return LoginScreen();
                                },
                              ),
                            );
                          }
                        } catch (e) {
                          String errorMessage =
                              'Gagal keluar: Terjadi kesalahan yang tidak diketahui.';
                          if (e is TimeoutException) {
                            errorMessage =
                                'Gagal keluar: Koneksi ke server bermasalah.';
                          } else if (e is SocketException) {
                            errorMessage =
                                'Gagal keluar: Tidak ada koneksi internet.';
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage,
                                  style: GoogleFonts.plusJakartaSans(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
        SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
