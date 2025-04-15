import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:pin_code_fields/pin_code_fields.dart';

import '../../theme/app_colors.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  BuildContext? _dialogContext;
  bool _isLoading = false;
  String? otpError;
  String? detailsError;
  String? generalError;
  String? nonFieldError;
  String otp = "";
  String? email;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      email = args.toString();
      print("otpScreen  ${email}");

    } else {
      // Handle the case when args is null
      print('No arguments provided');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Otp Screen",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),

      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
        //    crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height: 16),
              _buildErrorMessages(),
              SizedBox(height: 20),
              Image.asset(
                'assets/cloudberrylogo.png',
                height: 50,
              ),
              SizedBox(height: 24),
              Text(
                'Verification',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              SizedBox(height: 8),
              Text(
                "Enter the OTP code sent to your email",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              _buildPinCodeField(),
              SizedBox(height: 24),
              Text(
                "Didn't receive a code?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
           //   _buildResendButton(context),
            ],
          ),
        ),
      ),
    /*  bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: _buildVerifyButton(context),
      ),*/
    );
  }

  Widget _buildErrorMessages() {
    return Column(
      children: [
        if (generalError != null)
          Text(generalError!, style: const TextStyle(color: Colors.red)),
        if (nonFieldError != null)
          Text(nonFieldError!, style: const TextStyle(color: Colors.red)),
        if (detailsError != null)
          Text(detailsError!, style: const TextStyle(color: Colors.red)),
        if (otpError != null)
          Center(child: Text(otpError!, style: const TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primaryGreenColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Image.asset('assets/cloudberrylogo.png', fit: BoxFit.cover),
    );
  }

  Widget _buildPinCodeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PinCodeTextField(
        appContext: context,
        length: 4,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: 55,
          fieldWidth: 45,
          inactiveColor: Colors.grey[300],
          activeColor: AppColors.primaryGreenColor,
          selectedColor: Colors.deepPurpleAccent,
          inactiveFillColor: Colors.white,
          activeFillColor: Colors.white,
          selectedFillColor: Colors.white,
        ),
        animationDuration: Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        onCompleted: (v) => otp = v,
        onChanged: (value) => setState(() => otp = value),
      ),
    );
  }

  /*Widget _buildResendButton(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordLoadingState) {
          _showLoadingDialog();
        } else {
          _dismissLoadingDialog();
          if (state is ChangePasswordNonFieldErrorState) {
            setState(() => nonFieldError = state.nonFieldErrors?['non_field_errors']?.join(', '));
          } else if (state is ChangePasswordGeneralFieldErrorState) {
            setState(() => generalError = state.generalFieldErrors?['errors']?.join(', '));
          } else if (state is ChangePasswordFieldErrorState) {
            setState(() => generalError = null);
          } else if (state is ChangePasswordSuccessState) {
            showCustomSnackBar(context, "OTP resent");
          }
        }
      },
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              generalError = null;
              nonFieldError = null;
            });
            BlocProvider.of<ChangePasswordCubit>(context).changePassword(
              ChangePasswordRequest(email: email),
            );
          },
          child: Text('Resend New Code', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(


            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }*/

/*  Widget _buildVerifyButton(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpLoadingState) _showLoadingDialog();
        else if (state is OtpGeneralFieldErrorState) {
          setState(() => generalError = state.generalFieldErrors?['errors']?.join(', '));
          _dismissLoadingDialog();
        } else if (state is OtpFieldErrorState) {
          setState(() {
            otpError = state.fieldErrors?['otp']?.join(', ');
            detailsError = state.fieldErrors?['detail']?.join(', ');
          });
          _dismissLoadingDialog();
        } else if (state is OtpNonFieldErrorState) {
          setState(() => nonFieldError = state.nonFieldErrors?['non_field_errors']?.join(', '));
          _dismissLoadingDialog();
        } else if (state is OtpSuccessState) {
          _dismissLoadingDialog();
          Navigator.of(context).pushNamed(
            PageRoutes.changePasswordScreen,
            arguments: {'email': email, 'otp': otp},
          );
        }
      },
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            BlocProvider.of<OtpCubit>(context).otp(OtpRequest(otp: int.tryParse(otp) ?? 0));
          },
          child: const Text("Verify", style: TextStyle(fontSize: 18, color: Colors.white)),
        );
      },
    );
  }*/

  void _showLoadingDialog() {
    if (!_isLoading) {
      _isLoading = true;
      _dialogContext = context;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }
  }

  void _dismissLoadingDialog() {
    if (_isLoading && _dialogContext != null) {
      Navigator.of(_dialogContext!, rootNavigator: true).pop();
      _isLoading = false;
      _dialogContext = null;
    }
  }
}
