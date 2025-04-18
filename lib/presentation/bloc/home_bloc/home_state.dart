abstract class HomeState {}

class HomeInitial extends HomeState {}

class UpdateBottomNavigationState extends HomeState {
  final int index;

  UpdateBottomNavigationState({required this.index});
}
