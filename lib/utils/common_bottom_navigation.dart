import 'package:flutter/material.dart';
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
    return BottomNavigationBar(
      selectedItemColor: Color(0XFF7653F6),
      unselectedItemColor: Colors.grey,
      currentIndex: widget.selectedIndex,
      backgroundColor: Colors.white,
      onTap: (index) {

        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(
              context, PageRoutes.home, (route) => false);
          setState(() {

          });



        } else if (index == 1) {
          Navigator.pushNamedAndRemoveUntil(
              context, PageRoutes.profile, (route) => false);
          setState(() {

          });

        } else if (index == 2) {
          Navigator.pushNamedAndRemoveUntil(
              context, PageRoutes.orderHistory, (route) => false);
          setState(() {

          });

        }
        widget.onItemTapped(index);
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 26,),label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26,), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.history, size: 26,), label: ""),
      ],
    );
  }
}
