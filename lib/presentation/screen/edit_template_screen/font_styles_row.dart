import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pride/theme/app_colors.dart';

class FontStylesRow extends StatefulWidget {
  final double? fontSize;
  final double? definedFontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Function(double fontSize) onFontSizeChange;
  final Function(bool isBold) onBoldChange;
  final Function(bool isItalic) onItalicChange;
  final Function(bool isUnderline) onUnderlineChange;
  const FontStylesRow(
      {super.key,
      this.fontSize,
      this.definedFontSize,
      required this.isBold,
      required this.isItalic,
      required this.isUnderline,
      required this.onFontSizeChange,
      required this.onBoldChange,
      required this.onItalicChange,
      required this.onUnderlineChange});

  @override
  State<FontStylesRow> createState() => _FontStylesRowState();
}

class _FontStylesRowState extends State<FontStylesRow> {
  final MenuController _menuController = MenuController();

  List<int> generateFontSizes(double? fontSize) {
    if (fontSize == null) return [10, 11, 12, 13, 14, 15];

    int baseSize = fontSize.toInt();
    return [baseSize - 2, baseSize - 1, baseSize, baseSize + 1, baseSize + 2]
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final fontSizes =
        generateFontSizes(widget.definedFontSize ?? widget.fontSize);
    return Row(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MenuAnchor(
          controller: _menuController,
          style: MenuStyle(
            elevation: WidgetStateProperty.resolveWith((states) => 0),
            backgroundColor: WidgetStateColor.resolveWith(
              (state) => AppColors.whiteColor,
            ),
            padding:
                WidgetStateProperty.resolveWith((states) => EdgeInsets.zero),
            fixedSize: WidgetStateProperty.resolveWith(
                (states) => const Size.fromWidth(130)),
            shape: WidgetStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.violetBlue,
                        width: 1,
                      ),
                    )),
          ),
          menuChildren: [
            for (var size in fontSizes)
              GestureDetector(
                onTap: () {
                  widget.onFontSizeChange(size.toDouble());
                  _menuController.close();
                },
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20),
                  child: Text(
                    '$size px',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoalGray),
                  ),
                ),
              ),
          ],
          builder: (context, controller, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      'Font Size',
                      style: GoogleFonts.instrumentSans(
                        color: AppColors.black20,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.71,
                        letterSpacing: 0.14,
                      ),
                    )),
                GestureDetector(
                  onTap: () {
                    _menuController.open();
                  },
                  child: Container(
                    width: 130,
                    height: 54,
                    margin: const EdgeInsets.only(left: 20, right: 10),
                    padding: const EdgeInsets.all(14),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x667F879E),
                          blurRadius: 7,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        SvgPicture.asset('assets/icons/font_size.svg'),
                        Expanded(
                          child: Text(
                            widget.fontSize?.toString() ??
                                widget.definedFontSize?.toString() ??
                                'Font Size',
                            style: GoogleFonts.nunitoSans(
                              color: const Color(0xFF7F909F),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.71,
                              letterSpacing: 0.14,
                            ),
                          ),
                        ),
                        Text(
                          'px',
                          style: GoogleFonts.nunitoSans(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.71,
                            letterSpacing: 0.14,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const Spacer(),
        fontDecorators('assets/icons/bold.svg', isSelected: widget.isBold,
            onTap: () {
          widget.onBoldChange.call(!widget.isBold);
        }),
        fontDecorators('assets/icons/italic.svg', isSelected: widget.isItalic,
            onTap: () {
          widget.onItalicChange.call(!widget.isItalic);
        }),
        fontDecorators('assets/icons/underline.svg',
            isSelected: widget.isUnderline, onTap: () {
          widget.onUnderlineChange.call(!widget.isUnderline);
        }),
        const SizedBox(
          width: 5,
        )
      ],
    );
  }

  Widget fontDecorators(String svgIconPath,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        svgIconPath,
        colorFilter: isSelected
            ? const ColorFilter.mode(AppColors.violetBlue, BlendMode.srcIn)
            : null,
      ),
    );
  }
}
