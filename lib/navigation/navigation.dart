import 'package:flutter/material.dart';
import 'package:untitled/presentation/screen/order_details_screen/order_details_screen.dart';
import 'package:untitled/presentation/screen/student_form/student_form_screen.dart';
import 'package:untitled/presentation/screen/template_preview/template_preview_screen.dart';

import '../presentation/screen/change_password_screen.dart';
import '../presentation/screen/edit_template_screen/edit_template_screen.dart';
import '../presentation/screen/forget_screen.dart';
import '../presentation/screen/home_screen/home_screen.dart';
import '../presentation/screen/login_detail_screen.dart';
import '../presentation/screen/onboarding_screen/onboarding_screen.dart';
import '../presentation/screen/order_details_preview_screen/oder_details_preview_screen.dart';
import '../presentation/screen/order_history_screen/order_history_screen.dart';
import '../presentation/screen/profile_screen/profile_screen.dart';
import '../presentation/screen/splash_screen/splash_screen.dart';
import 'page_routes.dart';

class Navigation {
  static Route<dynamic>? onGenerateRoutes(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    switch (routeSettings.name) {

      case PageRoutes.splash:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => SplashScreen());
      case PageRoutes.onboarding:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => OnboardingScreen());

      case PageRoutes.login:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => LoginDetailScreen());
      case PageRoutes.forgotPassword:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => ForgetScreen());

      case PageRoutes.changePasswordScreen:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => ChangePasswordScreen());

      case PageRoutes.home:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => HomeScreen());


      case PageRoutes.profile:
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => ProfileScreen());


      case PageRoutes.studentFormDetails:
        final args = routeSettings.arguments as Map<String, dynamic>;
      final String id =  args['id'];
      final String? imageUrl = args['imageUrl'];
        final bool? isPortait = args['portait'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => StudentIDForm(id: id, imageUrl: imageUrl,isPortait : isPortait),
      );





      case PageRoutes.templatePreview:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final String? imageUrl = args['imageUrl'];
        final String? id = args['id'];
        final String? backImageUrl = args['backImageUrl'];

        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => TemplatePreviewScreen(imageUrl: imageUrl, id : id,backImageUrl: backImageUrl,),
        );

      case PageRoutes.orderHistory:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => OrderHistoryScreen());

      case PageRoutes.orderDetailsScreen:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final String? schoolId = args['schoolId'];
        final String? templateId = args['templateId'];
        final String? orderType = args['orderType'];
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => OrderDetailsScreen(schoolId: schoolId, templateId: templateId, orderType: orderType,));

      case PageRoutes.editTemplateScreen:

        final args = routeSettings.arguments as Map<String, dynamic>;
        final String? imageUrl = args['imageUrl'];
        final String? backImageUrl = args['backImageUrl'];
        final String? id = args['id'];
        final String? backFile = args['backFile'];
        final bool? isPortait = args['portait'];

        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => EditTemplateScreen(imageUrl: imageUrl, id: id, backImageUrl : backImageUrl,backFile: backFile));

      case PageRoutes.orderDetailsPreviewScreen:

        final args = routeSettings.arguments as Map<String, dynamic>;
        final String? imageUrl = args['imageUrl'];

        final String? id = args['id'];


        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => OrderDetailsPreviewScreen( orderId: id ?? '', imageUrl : imageUrl ?? ''));








      default:
    }
    return null;
  }
}
