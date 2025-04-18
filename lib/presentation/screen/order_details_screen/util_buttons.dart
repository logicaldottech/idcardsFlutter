import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UtilsButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const UtilsButton({super.key, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 34),
        decoration: ShapeDecoration(
          color: const Color(0xFF7653F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 2,
              ),
            )
          ],
        ),
      ),
    );
  }
}
