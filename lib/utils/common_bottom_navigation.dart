import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../navigation/page_routes.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavigationWidget({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    return BottomNavigationBar(
      selectedItemColor: Color(0XFF7653F6),
      unselectedItemColor: Colors.grey,
      currentIndex: widget.selectedIndex,
      backgroundColor: Colors.white,
      selectedLabelStyle: labelStyle,
      unselectedLabelStyle: labelStyle,
      onTap: (index) {
        widget.onItemTapped(index);
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 26,
            ),
            label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              size: 26,
            ),
            label: "Profile"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              size: 26,
            ),
            label: "History"),
      ],
    );
  }
}
