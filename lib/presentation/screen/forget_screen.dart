import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  _ForgetScreenState createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  BuildContext? _dialogContext;
  late bool _isLoading = false;
  String? emailError;
  String? generalError;
  String? nonFieldError;
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Set preferred orientations (optional)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Enable system overlays including status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Image.asset(
              'assets/cloudberrylogo.png',
              height: 50,
            ),
          ),
          //   const SizedBox(height: 24),
          //_header(context),

          _inputField(context),
        ],
      ),
      /*       bottomNavigationBar:  Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
            listener: (context, state) async {
              if (state is ChangePasswordLoadingState) {
                if (!_isLoading) {
                  _isLoading = true;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      _dialogContext = context;
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                }
              } else if (state is ChangePasswordNonFieldErrorState) {
                setState(() {
                  nonFieldError = state.nonFieldErrors?['non_field_errors']?.join(', ');
                });
                _dismissLoadingDialog();
              } else if (state is ChangePasswordGeneralFieldErrorState) {
                setState(() {
                  generalError = state.generalFieldErrors?['errors']?.join(', ');
                });
                _dismissLoadingDialog();
              } else if (state is ChangePasswordFieldErrorState) {
                setState(() {
                  emailError = state.fieldErrors?['email']?.join(', ');
                  generalError = null;
                  nonFieldError = null;
                });
                _dismissLoadingDialog();
              } else if (state is ChangePasswordSuccessState) {
                _dismissLoadingDialog();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context, )
                    .pushNamed(PageRoutes.Otp, arguments: emailController.text.toString());
              }
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  // Clear previous error messages
                  setState(() {
                    emailError = null;
                    generalError = null;
                    nonFieldError = null;
                  });

                  BlocProvider.of<ChangePasswordCubit>(context).changePassword(
                    ChangePasswordRequest(
                      email: emailController.text.isEmpty
                          ? null
                          : emailController.text.toString(),
                    ),
                  );
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50), // Set width to full
                ),
              );
            },
          ),
        ),*/
    );
  }

  _header(context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Forgot password?",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text("Recover if you have forgotten the password?"),
      ],
    );
  }

  _inputField(context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Email Address",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              errorText: emailError,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _dismissLoadingDialog() {
    if (_isLoading != null && _dialogContext != null) {
      Navigator.of(
        _dialogContext!,
      ).pop();
      _isLoading = false;
    }
  }
}
