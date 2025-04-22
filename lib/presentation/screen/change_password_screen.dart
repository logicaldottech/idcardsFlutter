import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart'; // Add Google Fonts for consistent typography
import 'package:pride/components/back_button.dart';
import 'package:pride/utils/loading_animation.dart';
import 'package:pride/utils/vl_toast.dart';

import '../../navigation/page_routes.dart';
import '../bloc/login_bloc/new_password_cubit.dart';
import '../bloc/login_bloc/new_password_state.dart';
import '../../domain/models/loginModels/new_password_request.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  BuildContext? _dialogContext;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? emailError;
  String? detailsError;
  String? generalError;
  String? nonFieldError;
  String? email;
  String? otp;
  bool _isButtonEnabled = false; // Add button enable/disable logic

  @override
  void initState() {
    super.initState();
    // Add listeners to validate input and enable/disable the button
    newPasswordController.addListener(_validateInput);
    oldPasswordController.addListener(_validateInput);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      email = args['email']?.toString();
      otp = args['otp']?.toString();
      print("createNewPassword $email  $otp");
    } else {
      email = null;
      otp = null;
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = newPasswordController.text.trim().isNotEmpty &&
          oldPasswordController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Padding(
              padding: EdgeInsets.only(left: 20), child: SLBackButton()),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Create New Password",
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please enter your new password",
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              if (generalError != null)
                Text(
                  generalError!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (nonFieldError != null)
                Text(
                  nonFieldError!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              _inputFields(),
            ],
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  Widget _inputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Old Password",
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: oldPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration:
              _inputDecoration("Enter your old password", Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "New Password",
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: newPasswordController,
          obscureText: !_isPasswordVisible,
          decoration:
              _inputDecoration("Enter your new password", Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.black54),
      hintText: hint,
      hintStyle: GoogleFonts.nunitoSans(
        color: Colors.black54,
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<NewPasswordCubit, NewPasswordState>(
      listener: (context, state) {
        if (state is NewPasswordLoadingState) {
          LoadingAnimation.show(context);
        } else if (state is NewPasswordSuccessState) {
          LoadingAnimation.hide(context);

          if (ModalRoute.of(context)?.impliesAppBarDismissal == true) {
            Navigator.maybePop(context);
          } else {
            Navigator.of(context).pushReplacementNamed(PageRoutes.home);
          }
          ToastUtils.showErrorToast("Reset password successfully");
        } else if (state is NewPasswordErrorState) {
          LoadingAnimation.hide(context);
          ToastUtils.showErrorToast(state.error);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _isButtonEnabled
                ? _submit
                : null, // Disable button if fields are empty
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                  0xFF7653F6), // Match the purple color from LoginDetailScreen
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    setState(() {
      emailError = null;
      generalError = null;
      nonFieldError = null;
    });
    BlocProvider.of<NewPasswordCubit>(context).newPassword(
      NewPasswordRequest(
        old_password: oldPasswordController.text,
        new_password: newPasswordController.text,
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    if (!_isLoading) {
      _isLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          _dialogContext = context;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
  }

  void _dismissLoadingDialog() {
    if (_isLoading && _dialogContext != null) {
      Navigator.of(
        _dialogContext!,
      ).pop();
      _dialogContext = null;
      _isLoading = false;
    }
  }
}
