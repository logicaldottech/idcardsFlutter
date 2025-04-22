import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pride/domain/models/template_models/template_response.dart';
import 'package:pride/navigation/page_routes.dart';
import 'package:pride/presentation/screen/home_screen/template_action_dialog.dart';
import 'package:pride/presentation/screen/student_form/student_form_screen.dart';
import 'package:pride/theme/app_colors.dart';

class TemplateCardView extends StatefulWidget {
  final Template template;
  const TemplateCardView({super.key, required this.template});

  @override
  State<TemplateCardView> createState() => _TemplateCardViewState();
}

class _TemplateCardViewState extends State<TemplateCardView> {
  final PageController _pageController = PageController(initialPage: 0);

  void showActionRequiredDialog(
    BuildContext context,
    Template template,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF7653F6),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Action Required',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Do you want to edit the card or want to add details?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            backgroundColor: Color(0xFF7653F6),
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
                            'Order Now',
                            style: GoogleFonts.poppins(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TemplateActionDialog.show(context, widget.template);
      },
      child: Container(
        width: double.maxFinite,
        height: 230,
        clipBehavior: Clip.hardEdge,
        decoration: ShapeDecoration(
          color: AppColors.paleLavender,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            )
          ],
        ),
        child: widget.template.edittemplateBackUrl != null
            ? _buildPageView()
            : _buildImage(widget.template.imageUrl),
      ),
    );
  }

  Widget _buildImage(String imgUrl) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      fit: widget.template.isPortait ? BoxFit.fitHeight : BoxFit.fill,
      errorWidget: (context, url, error) {
        return const Center(child: Icon(Icons.error_outline));
      },
    );
  }

  Widget _buildPageView() {
    return Stack(
      children: [
        Positioned.fill(
            child: PageView(
          controller: _pageController,
          children: [
            _buildImage(widget.template.imageUrl),
            _buildImage(widget.template.backImageUrl),
          ],
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SmoothPageIndicator(
                controller: _pageController, // PageController
                count: 2,
                effect: const ScrollingDotsEffect(
                    activeDotColor: AppColors.goldenYellow,
                    dotHeight: 8,
                    dotWidth: 8,
                    radius: 4), // your preferred effect
                onDotClicked: (index) {
                  _pageController.jumpToPage(index);
                }),
          ),
        ),
      ],
    );
  }
}
