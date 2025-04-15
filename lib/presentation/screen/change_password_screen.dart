import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/loginModels/new_password_request.dart';
import '../../navigation/page_routes.dart';
import '../bloc/login_bloc/new_password_cubit.dart';
import '../bloc/login_bloc/new_password_state.dart';

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
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create New Password",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (generalError != null)
              Text(generalError!, style: const TextStyle(color: Colors.red)),
            if (nonFieldError != null)
              Text(nonFieldError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            _inputFields(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _inputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(newPasswordController, "New Password", _isPasswordVisible, () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        }),
        const SizedBox(height: 12),
        _buildTextField(oldPasswordController, "Old Password", _isConfirmPasswordVisible, () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        }),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, bool isVisible, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Colors.grey[100],
        filled: true,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
          onPressed: toggleVisibility,
        ),
      ),
      obscureText: !isVisible,
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<NewPasswordCubit, NewPasswordState>(
      listener: (context, state) {
        if (state is NewPasswordLoadingState) {
          _showLoadingDialog(context);
        }

        else if (state is NewPasswordGeneralFieldErrorState) {
          setState(() {
            generalError = state.generalFieldErrors?['errors']?.join(', ');
          });
        } else if (state is NewPasswordSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reset password successfully")),
          );
          Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.home);
        }
        else  if (state is NewPasswordNonFieldErrorState) {
          _dismissLoadingDialog();
          setState(() {
            nonFieldError = state.nonFieldErrors?['non_field_errors']?.join(', ');
          });
        }
        else {
          _dismissLoadingDialog();

        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      Navigator.of(_dialogContext!, rootNavigator: true).pop();
      _dialogContext = null;
      _isLoading = false;
    }
  }
}
