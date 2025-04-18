import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class EditTemplateDialog extends StatefulWidget {
  final String selectedText;

  final double? fontSize;
  final double? definedFontSize;
  final Color? fontColor;
  final String? fontFamily;
  final bool? isBold;
  final bool? isItalic;
  final bool? isUnderline;
  final Function(
    double? fontSize,
    Color? fontColor,
    String? fontFamily,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
  ) onApply;
  const EditTemplateDialog(
      {super.key,
      required this.selectedText,
      required this.onApply,
      required this.fontSize,
      required this.fontColor,
      required this.fontFamily,
      required this.definedFontSize,
      required this.isBold,
      required this.isItalic,
      required this.isUnderline});

  @override
  State<EditTemplateDialog> createState() => _EditTemplateDialogState();
}

class _EditTemplateDialogState extends State<EditTemplateDialog> {
  double? tempFontSize;
  Color? tempFontColor;
  String? tempFontFamily;
  TextEditingController textController = TextEditingController();
  List<int> fontSizes = [];

  bool? isBold;
  bool? isItalic;
  bool? isUnderline;

  @override
  void initState() {
    super.initState();

    textController.text = widget.selectedText;
    tempFontColor = widget.fontColor;
    tempFontFamily = widget.fontFamily;
    tempFontSize = widget.fontSize;
    final availabelfontFamilies =
        _fontFamilies.where((e) => e == widget.fontFamily).toList();
    fontSizes = generateFontSizes(widget.definedFontSize ?? widget.fontSize);
    isBold = widget.isBold;
    isItalic = widget.isItalic;
    isUnderline = widget.isUnderline;
    setState(() {});
  }

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

  List<int> generateFontSizes(double? fontSize) {
    if (fontSize == null) return [10, 11, 12, 13, 14, 15];

    int baseSize = fontSize.toInt();
    return [baseSize - 2, baseSize - 1, baseSize, baseSize + 1, baseSize + 2]
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Edit Text"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: textController,
              readOnly: true,
            ),
            SizedBox(height: 10),
            //create a dropdown to select font family
            Text("Font Family"),
            DropdownButton<String>(
              isExpanded: true,
              value: tempFontFamily,
              items: _fontFamilies.map((String fontFamily) {
                return DropdownMenuItem<String>(
                  value: fontFamily,
                  child: Text(fontFamily),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  tempFontFamily = value;
                });
              },
              hint: Text('Select Font Family'),
            ),
            SizedBox(height: 10),

            Text("Font Decoration"),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChoiceChip(
                label: const Icon(Icons.format_bold, size: 24),
                padding: const EdgeInsets.all(4),
                selected: isBold ?? false,
                onSelected: (value) {
                  setState(() => isBold = value);
                },
              ),
              ChoiceChip(
                label: const Icon(Icons.format_italic, size: 24),
                selected: isItalic ?? false,
                padding: const EdgeInsets.all(4),
                onSelected: (value) {
                  setState(() => isItalic = value);
                },
              ),
              ChoiceChip(
                label: const Icon(Icons.format_underline, size: 24),
                selected: isUnderline ?? false,
                padding: const EdgeInsets.all(4),
                onSelected: (value) {
                  setState(() => isUnderline = value);
                },
              ),
            ]),
            SizedBox(height: 10),

            Text("Font Size"),
            Wrap(
              spacing: 8,
              children: List.generate(fontSizes.length, (index) {
                int size = fontSizes[index];
                return ChoiceChip(
                  label: Text("$size"),
                  selected: tempFontSize == size.toDouble(),
                  onSelected: (_) {
                    setState(() => tempFontSize = size.toDouble());
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            Text("Font Color"),
            const SizedBox(height: 8),
            _colorBox(
              tempFontColor ?? Colors.transparent,
            ),
            const SizedBox(height: 8),
            ColorPicker(
              color: tempFontColor ?? Colors.transparent,
              onColorChanged: (Color color) {
                setState(() {
                  tempFontColor = color;
                });
              },
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply.call(
              tempFontSize,
              tempFontColor,
              tempFontFamily,
              isBold,
              isItalic,
              isUnderline,
            );
            Navigator.maybePop(context);
          },
          child: Text("Apply"),
        ),
      ],
    );
  }

  Widget _colorBox(
    Color color,
  ) {
    return Row(
      spacing: 20,
      children: [
        Text('Selected Color :- '),
        Container(
          width: 30,
          height: 30,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}
