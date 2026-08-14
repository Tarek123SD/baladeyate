import 'package:baladeyate/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showErrorDialog(BuildContext context, String errorMessage) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Error',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox(),
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
        child: FadeTransition(
          opacity: anim1,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.cornerRadius(16)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: context.dim(16)),
                Icon(
                  Icons.gpp_bad_outlined,
                  color: Colors.red.shade600,
                  size: context.iconSize(60),
                ),
                SizedBox(height: context.dim(10)),
                Text(
                  'حدث خطأ',
                  style: GoogleFonts.poppins(
                    fontSize: context.text(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.dim(8)),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: context.text(14),
                  ),
                ),
                SizedBox(height: context.dim(24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: context.dim(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.cornerRadius(12)),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'حسناً',
                      style: TextStyle(fontSize: context.text(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
