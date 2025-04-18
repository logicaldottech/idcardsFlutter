import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/components/back_button.dart';
import 'package:untitled/navigation/page_routes.dart';
import 'package:untitled/presentation/bloc/edit_profile_bloc/edit_profile_cubit.dart';
import 'package:untitled/presentation/bloc/profile_bloc/profile_cubit.dart';
import 'package:untitled/utils/loading_animation.dart';
import 'package:untitled/utils/vl_toast.dart';

import '../../../domain/models/edit_profile_models/edit_profile_request.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_request.dart';
import '../../bloc/edit_profile_bloc/edit_profile_state.dart';
import '../../bloc/upload_file_bloc/upload_file_cubit.dart';
import '../../bloc/upload_file_bloc/upload_file_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? logo;
  @override
  void initState() {
    super.initState();
    // Pre-fill the fields with existing user data (e.g., fetched from an API or local storage)
    final user = context.read<ProfileCubit>().currentUser;
    logo = user?.data.logo;
    _fullNameController.text = user?.data.fullName ?? ''; // Example data
    _emailController.text = user?.data.email ?? ''; // Example data
  }

  Future<void> _showImagePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.maybePop(context);

                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Capture from Camera'),
                onTap: () {
                  Navigator.maybePop(context);

                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile =
          await ImageCropper().cropImage(sourcePath: pickedFile.path);
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
        _uploadImage(_image!);
      }
    }
  }

  void _uploadImage(File imageFile) {
    final request = ExternalUploadFileRequest(file: imageFile);
    context.read<UploadFileCubit>().fetchUploadedFiles(request: request);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
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
      Navigator.of(
        context,
      ).pop();
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Edit Profile",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0XFF262626),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
              padding: EdgeInsets.only(left: 20), child: SLBackButton()),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlocBuilder<UploadFileCubit, UploadFileState>(
                  builder: (context, state) {
                    if (state is UploadFileLoadingState) {
                      return const Center();
                    } else if (state is UploadFileSuccessState) {
                      logo =
                          "https://api.todaystrends.site/externalFiles/${state.response.fileName}";
                    } else if (state is UploadFileErrorState) {}
                    return Center();
                  },
                ),

                // Profile Image
                GestureDetector(
                  onTap: _showImagePicker,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : logo != null
                                  ? CachedNetworkImage(
                                      imageUrl: logo!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Image.network(
                                      "https://via.placeholder.com/150", // Replace with existing profile image URL if available
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF7653F6),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name Field
                    Text(
                      "Full Name",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _fullNameController,
                      decoration: _inputDecoration(
                        "Enter your name",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Email",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        "Enter your email",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
              if (state is EditProfileRequestLoadingState) {
                LoadingAnimation.show(context);
              } else if (state is EditProfileSuccessState) {
                LoadingAnimation.hide(context);
                context.read<ProfileCubit>().fetchProfile();
                Navigator.maybePop(context);
              } else if (state is EditProfileErrorState) {
                LoadingAnimation.hide(context);
                ToastUtils.showErrorToast(state.error);
              }
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  EditProfileRequest editProfileRequest = EditProfileRequest(
                      fullName: _fullNameController.text.toString(),
                      email: _emailController.text.toString(),
                      logo: logo);
                  context
                      .read<EditProfileCubit>()
                      .editProfile(editProfileRequest);
                },
                child: Text("Submit",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7653F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
