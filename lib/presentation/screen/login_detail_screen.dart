import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../navigation/page_routes.dart';
import '../../theme/app_colors.dart';
import '../bloc/login_bloc/login_cubit.dart';
import '../bloc/login_bloc/login_state.dart';
import '../../domain/models/loginModels/login_request.dart';

class LoginDetailScreen extends StatefulWidget {
  @override
  _LoginDetailScreenState createState() => _LoginDetailScreenState();
}

class _LoginDetailScreenState extends State<LoginDetailScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateInput);
    passwordController.addListener(_validateInput);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  void _validateInput() {
    setState(() {
      _isButtonEnabled =
          emailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty;
    });
  }
  void showLoginSuccessBottomSheetPopUp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginSuccessBottomSheet(),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Welcome Back",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Please sign in with your account", style: TextStyle(fontSize: 16, color: Colors.black54)),
            SizedBox(height: 32),
            _inputField(),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginLoadingState) {
              _showLoadingDialog();
            } else if (state is LoginSuccessState) {
              _dismissLoadingDialog();
              showLoginSuccessBottomSheetPopUp(context);
           //   showLoginSuccessBottomSheet(context, state.response.data.isAdminPassword.toString());

              

            } else {
              _dismissLoadingDialog();
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: _isButtonEnabled ? _handleLogin : null,
              child: Text("Sign In", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7653F6) ,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _inputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: emailController,
          decoration: _inputDecoration("Enter your email", Icons.email),
        ),
        SizedBox(height: 16),
        Text("Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: _inputDecoration("Enter your password", Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _handleLogin() {
    BlocProvider.of<LoginCubit>(context).login(
      LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        deviceToken: "deviceToken",
        deviceType: 1,
      ),
    );
  }

  void _showLoadingDialog() {
    if (!_isLoading) {
      _isLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
    }
  }

  void _dismissLoadingDialog() {
    if (_isLoading) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoading = false;
    }
  }
}
class LoginSuccessBottomSheet extends StatelessWidget {
  const LoginSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              "assets/image/bottomsheet_logo.png",
              width: 320,
              height: 320,
            ),
            const SizedBox(height: 20),
            Text(
              "Yay! Login Successful",
              style: GoogleFonts.nunitoSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You will be redirected to the home screen.\nEnjoy the features!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7653F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {

                 Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.home);
                },
                child: Text(
                  "Sign In",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

