import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pride/presentation/bloc/create_order_bloc/create_order_cubit.dart';
import 'package:pride/presentation/bloc/edit_profile_bloc/edit_profile_cubit.dart';
import 'package:pride/presentation/bloc/home_bloc/home_cubit.dart';
import 'package:pride/presentation/bloc/login_bloc/change_password_cubit.dart';
import 'package:pride/presentation/bloc/login_bloc/login_cubit.dart';
import 'package:pride/presentation/bloc/login_bloc/new_password_cubit.dart';
import 'package:pride/presentation/bloc/logout_bloc/logout_cubit.dart';
import 'package:pride/presentation/bloc/order_details_preview_bloc/order_details_preview_cubit.dart';
import 'package:pride/presentation/bloc/order_history_bloc/order_history_cubit.dart';
import 'package:pride/presentation/bloc/profile_bloc/profile_cubit.dart';
import 'package:pride/presentation/bloc/student_form_cubit/student_form_cubit.dart';
import 'package:pride/presentation/bloc/template_bloc/template_cubit.dart';
import 'package:pride/presentation/bloc/update_template_bloc/update_template_cubit.dart';
import 'package:pride/presentation/bloc/upload_file_bloc/upload_file_cubit.dart';

import 'bloc_observer.dart';
import 'domain/repositories/main_repository.dart';
import 'navigation/navigation.dart';
import 'navigation/page_routes.dart';

import 'package:chucker_flutter/chucker_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.grey.withOpacity(0.5), // Set your desired color
      statusBarIconBrightness:
          Brightness.light, // For white icons on dark background
      // statusBarBrightness: Brightness.dark, // Use this on iOS if needed
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => MainRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
          BlocProvider<ChangePasswordCubit>(
              create: (context) => ChangePasswordCubit()),
          BlocProvider<NewPasswordCubit>(
              create: (context) => NewPasswordCubit()),
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
          BlocProvider<TemplateCubit>(create: (context) => TemplateCubit()),
          BlocProvider<StudentFormCubit>(
              create: (context) => StudentFormCubit()),
          BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
          BlocProvider<CreateOrderCubit>(
              create: (context) => CreateOrderCubit()),
          BlocProvider<OrderHistoryCubit>(
              create: (context) => OrderHistoryCubit()),
          BlocProvider<LogoutCubit>(create: (context) => LogoutCubit()),
          BlocProvider<UpdateTemplateCubit>(
              create: (context) => UpdateTemplateCubit()),
          BlocProvider<UploadFileCubit>(create: (context) => UploadFileCubit()),
          BlocProvider<OrderDetailsPreviewCubit>(
              create: (context) => OrderDetailsPreviewCubit()),
          BlocProvider<EditProfileCubit>(
              create: (context) => EditProfileCubit()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: PageRoutes.splash,
          // Changed to login screen route
          debugShowCheckedModeBanner: false,
          onGenerateRoute: Navigation.onGenerateRoutes,
          navigatorObservers: [
            ChuckerFlutter.navigatorObserver,
          ],
          color: Colors.white,
        ),
      ),
    );
  }
}
