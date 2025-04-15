import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/data_sources/local/preference_utils.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _navigateToNextScreen() async {


    String? token = await PreferencesUtil.getString(AppConstants.authToken);
    print("tokenBearer ${token}");


    if ( token?.isNotEmpty==true) {
      Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.home);
    } else {
      Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[300]!, Colors.black],
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60),

              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset("assets/image/logo.png", width: 138),
                    SizedBox(height: 12),
                  ],
                ),
              ),

              Spacer(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Turn your moments \nlike magic now!",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                          "Vivamus vel ex sit amet neque dignissim mattis non eu est.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),

              // Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToNextScreen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Start Now",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: index == 1 ? 10 : 6,
                    height: index == 1 ? 10 : 6,
                    decoration: BoxDecoration(
                      color: index == 1 ? Colors.white : Colors.white38,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}