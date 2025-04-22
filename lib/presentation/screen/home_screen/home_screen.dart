import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pride/presentation/bloc/home_bloc/home_cubit.dart';
import 'package:pride/presentation/bloc/home_bloc/home_state.dart';
import 'package:pride/presentation/screen/home_screen/home_page.dart';
import 'package:pride/presentation/screen/order_history_screen/order_history_screen.dart';
import 'package:pride/presentation/screen/profile_screen/profile_screen.dart';
import 'package:pride/utils/common_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is UpdateBottomNavigationState) {
            if (_pageController.page?.toInt() != state.index) {
              _pageController.jumpToPage(state.index);
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              selectedIndex.value = index;
            },
            children: [
              const HomePage(),
              const ProfileScreen(),
              OrderHistoryScreen()
            ],
          ),
          bottomNavigationBar: ValueListenableBuilder(
              valueListenable: selectedIndex,
              builder: (context, selectedIndexValue, child) {
                return BottomNavigationWidget(
                  selectedIndex: selectedIndexValue,
                  onItemTapped: (index) {
                    selectedIndex.value = index;
                    _pageController.jumpToPage(index);
                  },
                );
              }),
        ),
      ),
    );
  }
}
