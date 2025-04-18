import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/domain/models/template_models/template_response.dart';
import 'package:untitled/navigation/page_routes.dart';
import 'package:untitled/presentation/screen/student_form/student_form_screen.dart';
import 'package:untitled/theme/app_colors.dart';

class TemplateActionDialog extends StatelessWidget {
  final Template template;
  const TemplateActionDialog({super.key, required this.template});

  static void show(BuildContext context, Template template) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: TemplateActionDialog(template: template));
      },
    );
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
            height: 50,
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
              'Action Required',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Do you want to edit the card or want to add details?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.of(context).pushNamed(
                        PageRoutes.editTemplateScreen,
                        arguments: template);
                    // Add edit action here
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text('Edit Now', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.violetBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.of(context).pushNamed(
                      PageRoutes.studentFormDetails,
                      arguments: StudentFormArguments(id: template.id!),
                    );
                    // Add order action here
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.black87,
                    size: 18,
                  ),
                  label: Text(
                    'Enter Details',
                    style: GoogleFonts.poppins(color: Colors.black87),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
