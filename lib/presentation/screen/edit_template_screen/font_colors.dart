import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pride/theme/app_colors.dart';

class FontColors extends StatelessWidget {
  final Color? fontColor;
  final Function(Color color) onFontColorChanged;
  const FontColors(
      {super.key, this.fontColor, required this.onFontColorChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Font Color',
                style: GoogleFonts.instrumentSans(
                  color: AppColors.black20,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.71,
                  letterSpacing: 0.14,
                ),
              )),
          ColorPicker(
            color: fontColor ?? Colors.transparent,
            onColorChanged: onFontColorChanged,
            pickersEnabled: {
              ColorPickerType.wheel: true, // Enables color wheel
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
            },
            enableOpacity: true, // Enables opacity slider
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }
}
