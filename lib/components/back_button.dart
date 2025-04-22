import 'package:flutter/material.dart';
import 'package:pride/theme/app_colors.dart';

class SLBackButton extends StatelessWidget {
  const SLBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.impliesAppBarDismissal == true) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
