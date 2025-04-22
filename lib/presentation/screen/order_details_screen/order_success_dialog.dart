import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pride/navigation/page_routes.dart';
import 'package:pride/presentation/bloc/home_bloc/home_cubit.dart';
import 'package:pride/theme/app_colors.dart';

class OrderSuccessDialog extends StatefulWidget {
  const OrderSuccessDialog({super.key});

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();

  static void show(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: OrderSuccessDialog()),
    );
  }
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog> {
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
    Navigator.pop(context);

    Navigator.popUntil(
        context, (route) => route.settings.name == PageRoutes.home);
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
          color: AppColors.whiteColor, borderRadius: BorderRadius.circular(24)),
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
              'Congratulation',
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
                      color: AppColors.black.withOpacity(0.35))
                ]),
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
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Order placed successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<HomeCubit>().updateBottomNav(2);
                  if (mounted) {
                    navigateToHomeScreen();
                  }
                },
                icon: const Icon(
                  Icons.history,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'Go to Order History',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 2,
                      color: AppColors.whiteColor),
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
          const SizedBox(
            height: 18,
          )
        ],
      ),
    );
  }
}
