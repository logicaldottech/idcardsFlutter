import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/theme/app_colors.dart';

class PasswordChangeSuccessDialog extends StatefulWidget {
  const PasswordChangeSuccessDialog({Key? key}) : super(key: key);

  @override
  _PasswordChangeSuccessDialogState createState() => _PasswordChangeSuccessDialogState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: PasswordChangeSuccessDialog()),
    );
  }
}

class _PasswordChangeSuccessDialogState extends State<PasswordChangeSuccessDialog> {
  ValueNotifier<int> countdown = ValueNotifier<int>(5);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer?.cancel();
        timer = null;
        if (mounted) {
          navigateToHomeScreen();
        }
      }
    });
  }

  void navigateToHomeScreen() {
    Navigator.popUntil(context, ModalRoute.withName('/home'));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.maxFinite,
            height: 55,
            decoration: const ShapeDecoration(
              color: AppColors.violetBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.center,
            child: Text(
              'Password Changed',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            height: 74,
            width: 74,
            margin: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: AppColors.violetBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                  blurRadius: 4,
                  color: AppColors.black.withOpacity(0.35),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ValueListenableBuilder(
              valueListenable: countdown,
              builder: (context, value, child) {
                return Text(
                  '0$value',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your password has been updated successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: navigateToHomeScreen,
                icon: const Icon(
                  Icons.home,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'Go to Home Page',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 2,
                    color: AppColors.whiteColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.violetBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
