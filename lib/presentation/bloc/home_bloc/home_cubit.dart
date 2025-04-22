import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pride/presentation/bloc/home_bloc/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void updateBottomNav(int index) {
    emit(UpdateBottomNavigationState(index: index));
  }
}
