import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled/theme/app_colors.dart';

import '../../../navigation/page_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "image": "assets/image/onboarding_1.png", // Add relevant images
      "title": "Choose a Template",
      "description":
          "Pick a design you like and decide to customize or fill details."
    },
    {
      "image": "assets/image/onboarding_2.png",
      "title": "Customize or Add Info",
      "description":
          "Edit colors and fonts, or directly fill in your personal details."
    },
    {
      "image": "assets/image/onboarding_3.png",
      "title": "Preview and Submit",
      "description":
          "Check the final look, then submit to get your ready-to-use card."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  isSkippable: !(index == onboardingData.length - 1),
                  image: onboardingData[index]["image"]!,
                  title: onboardingData[index]["title"]!,
                  description: onboardingData[index]["description"]!,
                  onSkip: () {
                    Navigator.of(context)
                        .pushReplacementNamed(PageRoutes.login);
                  },
                ),
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SmoothPageIndicator(
                        controller: _pageController, // PageController
                        count: 3,
                        effect: const ScrollingDotsEffect(
                            activeDotColor: AppColors.goldenYellow,
                            dotHeight: 10,
                            dotWidth: 10,
                            radius: 5), // your preferred effect
                        onDotClicked: (index) {
                          _pageController.jumpToPage(index);
                        }),
                    const SizedBox(
                      height: 77,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          if (_pageController.page?.toInt() ==
                              onboardingData.length - 1) {
                            Navigator.of(context)
                                .pushReplacementNamed(PageRoutes.login);
                          } else {
                            _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          }
                        },
                        child: Container(
                          width: 118,
                          height: 50,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF7653F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: AppColors.whiteColor,
                            size: 30,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: _currentPage == index ? 16 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String image, title, description;
  final bool isSkippable;
  final VoidCallback? onSkip;

  const OnboardingContent(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      this.onSkip,
      required this.isSkippable});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isSkippable)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GestureDetector(
                  onTap: onSkip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.charcoalGray),
                  ),
                ),
              ),
            )
          else
            const SizedBox(
              height: 18,
            ),
          const Spacer(),
          SizedBox(
            height: 220,
            width: 220,
            child: Stack(
              children: [
                Container(
                  height: 220,
                  width: 220,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.violetBlue),
                  padding: const EdgeInsets.all(32),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 16,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.goldenYellow),
                  ),
                )
              ],
            ),
          ),
          // Make sure to add images in assets
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.black),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: AppColors.charcoalGray),
          ),
        ],
      ),
    );
  }
}
