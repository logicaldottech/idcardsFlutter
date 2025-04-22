import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pride/theme/app_colors.dart';

class FontFamilyDropDown extends StatefulWidget {
  final String? selectedFontFamily;
  final Function(String fontFamily) onFontFamilyChanged;
  const FontFamilyDropDown(
      {super.key, this.selectedFontFamily, required this.onFontFamilyChanged});

  @override
  State<FontFamilyDropDown> createState() => _FontFamilyDropDownState();
}

class _FontFamilyDropDownState extends State<FontFamilyDropDown> {
  final MenuController _menuController = MenuController();
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  final _fontFamilies = [
    "Arial",
    "Times New Roman",
    "Georgia",
    "Impact",
    "Montserrat",
    "Roboto",
    "Open Sans",
    "Lato",
    "Poppins",
    "Raleway",
    "Bebas Neue",
    "Lora",
    "Playfair Display",
    "Oswald",
    "Nunito",
    "Source Sans Pro",
    "Merriweather",
    "Rubik",
    "Inter",
    "Calibri",
    "Verdana",
    "Cambria",
    "Garamond",
    "Helvetica",
    "Tahoma",
    "Trebuchet MS",
    "Century Gothic"
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MenuAnchor(
        controller: _menuController,
        onOpen: () {
          _isExpanded.value = true;
        },
        onClose: () {
          _isExpanded.value = false;
        },
        style: MenuStyle(
          elevation: WidgetStateProperty.resolveWith((states) => 0),
          backgroundColor: WidgetStateColor.resolveWith(
            (state) => AppColors.whiteColor,
          ),
          padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.zero),
          fixedSize: WidgetStateProperty.resolveWith((states) => Size(
              constraints.maxWidth, MediaQuery.of(context).size.height * 0.5)),
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
          for (var fontFamily in _fontFamilies)
            GestureDetector(
              onTap: () {
                widget.onFontFamilyChanged(fontFamily);
                _menuController.close();
              },
              child: Container(
                width: constraints.maxWidth,
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                child: Text(
                  fontFamily,
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
                    'Font Family',
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
                  width: double.maxFinite,
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      SvgPicture.asset('assets/icons/font_family.svg'),
                      Expanded(
                        child: Text(
                          widget.selectedFontFamily ?? 'Font Name',
                          style: GoogleFonts.nunitoSans(
                            color: const Color(0xFF7F909F),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.71,
                            letterSpacing: 0.14,
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                          valueListenable: _isExpanded,
                          builder: (context, isExpanded, child) {
                            return Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_outlined
                                    : Icons.keyboard_arrow_down_outlined,
                                color: Colors.black);
                          }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
