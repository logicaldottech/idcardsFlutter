import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/components/back_button.dart';
import 'package:untitled/components/success_dialog.dart';
import 'package:untitled/domain/models/student_form_models/order_pre_data.dart';
import 'package:untitled/domain/models/student_form_models/student_form_response.dart';
import 'package:untitled/presentation/screen/order_details_screen/order_details_screen.dart';
import 'package:untitled/theme/app_colors.dart';
import 'package:untitled/utils/loading_animation.dart';
import 'package:untitled/utils/vl_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/data_sources/local/database_helper.dart';
import '../../../data/data_sources/local/preference_utils.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_request.dart';
import '../../../domain/models/student_form_models/student_form_request.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/app_constants.dart';
import '../../bloc/create_order_bloc/create_order_cubit.dart';
import '../../bloc/create_order_bloc/create_order_state.dart';
import '../../bloc/student_form_cubit/student_form_cubit.dart';
import '../../bloc/student_form_cubit/student_form_state.dart';
import '../../bloc/upload_file_bloc/upload_file_cubit.dart';
import '../../bloc/upload_file_bloc/upload_file_state.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

enum ImageMapperEnum {
  userImg,
  logoImg,
  signature;
}

class StudentFormArguments {
  final String id;
  final String? frontHtml;
  final String? backHtml;

  StudentFormArguments({required this.id, this.frontHtml, this.backHtml});
}

class StudentIDForm extends StatefulWidget {
  final StudentFormArguments args;
  const StudentIDForm({
    super.key,
    required this.args,
  });

  @override
  State<StudentIDForm> createState() => _StudentIDFormState();
}

class _StudentIDFormState extends State<StudentIDForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  File? _logoImage;
  File? _signatureImage;
  final picker = ImagePicker();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _backControllers = {};
  TemplateData? templateData;
  List<String> templateFields = [];
  // List<Map<String, dynamic>> _orderDataList = [];
  String studentId = "";
  String? uploadImage;
  String? logoImage;
  String? signatureImage;
  WebViewController? _webViewController; // Store the WebViewController
  WebViewController? _backWebViewController; // Store the WebViewController
  OrderPreData? editableRecord;
  Map<String, String> backRecords = {};
  PageController pageController = PageController(initialPage: 0);
  ValueNotifier<int> pageValue = ValueNotifier(0);
  // Create a global key to identify the RepaintBoundary
  final GlobalKey _frontKey = GlobalKey();
  final GlobalKey _backKey = GlobalKey();

  Uint8List? frontPngBytes;
  Uint8List? backPngBytes;
  // Function to capture the widget as an image
  Future<Uint8List?> _captureImage(GlobalKey key) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      // Find the RenderRepaintBoundary using the global key
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the image with a higher pixel ratio for better quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        // You can now use the image bytes (for example, save or display them)
        print('Captured image with ${pngBytes.length} bytes');

        return pngBytes;
      }
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudentForm();
    _getStudentId();
  }

  void _getStudentId() async {
    studentId = (await PreferencesUtil.getString(AppConstants.schoolId)) ?? "";
    setState(() {});
  }

  void _fetchStudentForm() {
    context
        .read<StudentFormCubit>()
        .submitStudentForm(StudentFormRequest(id: widget.args.id));
  }

  Future<void> _showImagePicker(ImageMapperEnum mapperKey) async {
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

                  _pickImage(ImageSource.gallery, mapperKey: mapperKey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Capture from Camera'),
                onTap: () {
                  Navigator.maybePop(context);

                  _pickImage(ImageSource.camera, mapperKey: mapperKey);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source,
      {required ImageMapperEnum mapperKey}) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile =
          await ImageCropper().cropImage(sourcePath: pickedFile.path);
      final file = croppedFile != null ? File(croppedFile.path) : null;
      if (file != null) {
        switch (mapperKey) {
          case ImageMapperEnum.userImg:
            _image = file;
            break;
          case ImageMapperEnum.logoImg:
            _logoImage = file;
            break;
          case ImageMapperEnum.signature:
            _signatureImage = file;
            break;
        }

        setState(() {});

        _uploadImage(file, mapperKey);
      }
    }
  }

  void _uploadImage(File imageFile, ImageMapperEnum key) {
    final request = ExternalUploadFileRequest(file: imageFile);
    context
        .read<UploadFileCubit>()
        .fetchUploadedFiles(request: request, key: key);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }

      if (uploadImage?.isNotEmpty == true) {
        formData['https://api.todaystrends.site/externalFiles/userpic.png'] =
            uploadImage;
      }
      // _orderDataList.add(formData);

      // CreateOrderRequest request = CreateOrderRequest(
      //   schoolId: studentId,
      //   templateId: widget.id,
      //   orderType: 'array',
      //   orderData: _orderDataList,
      // );

      // context.read<CreateOrderCubit>().createOrder(request);
      // print('createOrderResponse: ${jsonEncode(request.toJson())}');
    }
  }

  Future<void> _addNewEntry() async {
    FocusScope.of(context).unfocus();

    if (templateData!.isLogoRequired && logoImage == null) {
      ToastUtils.showErrorToast('Add Logo image first');
      return;
    }
    if (templateData!.isSignatureRequired && signatureImage == null) {
      ToastUtils.showErrorToast('Add Signature first');
      return;
    }

    if (templateData?.edittemplateBackUrl != null &&
        templateData?.templateBackFields != null &&
        templateData!.templateBackFields!.isNotEmpty) {
      final isBackFormFilled = templateData?.templateBackFields
              ?.every((e) => _backControllers[e]?.text.isNotEmpty == true) ??
          false;
      if (!isBackFormFilled) {
        ToastUtils.showErrorToast('Fill back form first');
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }
      for (var entry in _backControllers.entries) {
        formData[entry.key] = entry.value.text;
      }
      if (uploadImage?.isNotEmpty == true) {
        formData['https://api.todaystrends.site/externalFiles/userpic.png'] =
            uploadImage;
      }

      String jsonData = json.encode(formData);

      context.read<StudentFormCubit>().addStudentDetails(jsonData,
          templateId: widget.args.id,
          logo: logoImage,
          signature: signatureImage);
      // _orderDataList.add(formData);
    }
  }

  Future<void> _updateRecord() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }
      for (var entry in _backControllers.entries) {
        formData[entry.key] = entry.value.text;
      }
      if (uploadImage?.isNotEmpty == true) {
        formData['https://api.todaystrends.site/externalFiles/userpic.png'] =
            uploadImage;
      }

      String jsonData = json.encode(formData);

      context
          .read<StudentFormCubit>()
          .updateStudentDetails(editableRecord!.id, jsonData, logo: logoImage);
      // _orderDataList.add(formData);
    }
  }

  void _clearData() {
    setState(() {
      for (var controller in _controllers.values) {
        controller.clear();
      }
      // _orderDataList.clear();
      uploadImage = null;
      _image = null;
    });
  }

  Future<void> _pickExcelFile() async {
    try {
      // Pick file with allowed Excel extensions
      FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
        final file = filePickerResult.files.first;
        final bytes = File(file.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        String sheetName = excel.tables.keys.first;
        var table = excel.tables[sheetName];

        List<Map<String, dynamic>> sheetData = [];

        if (table != null) {
          List<String> headers = [];
          for (int rowIndex = 0; rowIndex < table.maxRows; rowIndex++) {
            var row = table.rows[rowIndex];
            if (rowIndex == 0) {
              // Use first row as headers
              for (var cell in row) {
                headers.add(cell?.value?.toString() ?? '');
              }
            } else {
              Map<String, dynamic> rowData = {};
              for (int cellIndex = 0; cellIndex < headers.length; cellIndex++) {
                // Convert each cell value to string for JSON encodability
                rowData[headers[cellIndex]] = row[cellIndex]?.value?.toString();
              }
              sheetData.add(rowData);
            }
          }
        }

        // Store in a separate table 'excel_orders' for Excel uploads.
        final db = await DatabaseHelper.instance.database;
        final batch = db.batch();
        sheetData.forEach((data) async {
          String jsonData = json.encode(data);
          print("Excel JSON Data: $jsonData");
          batch.insert('orders', {
            'data': jsonData,
            'templateId': widget.args.id,
            if (logoImage != null) 'logo': logoImage,
            if (signatureImage != null) 'signature': signatureImage
          });
        });
        // Delete previous excel orders to replace with new data.

        try {
          final result = await batch.commit(continueOnError: false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File Uploaded Successfully!"),
              duration: Duration(seconds: 3),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong!"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No File Selected"),
            duration: Duration(seconds: 3),
          ),
        );
        debugPrint("No file selected");
      }
    } catch (e, stackTrace) {
      debugPrint("Error in _pickExcelFile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong!"),
          duration: Duration(seconds: 3),
        ),
      );
      debugPrint("$stackTrace");
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    _backControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            leading: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: SLBackButton(),
            ),
            actions: [
              // BlocBuilder<StudentFormCubit, StudentFormState>(
              //     builder: (context, state) {
              //   if (templateData?.isLogoRequired == true) {
              //     }
              //   return const SizedBox.shrink();
              // }),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final response = await Navigator.of(context).pushNamed(
                      PageRoutes.orderDetailsScreen,
                      arguments: OrderDetailsArguments(
                          schoolId: studentId,
                          template: templateData!,
                          orderType: 'array',
                          htmlFront: widget.args.frontHtml,
                          htmlBack: widget.args.backHtml,
                          frontThumbnailImage: frontPngBytes,
                          backThumbnailImage: backPngBytes));
                  if (response != null) {
                    editableRecord = response as OrderPreData;
                    log(response.toString());
                    _autofillData();
                  } else {
                    editableRecord = null;
                  }
                },
                child: Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.violetBlue,
                  ),
                  child: const Icon(
                    Icons.visibility,
                    color: AppColors.whiteColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 20)
            ],
            backgroundColor: Colors.white,
          ),
          body: MultiBlocListener(
              listeners: [
                BlocListener<UploadFileCubit, UploadFileState>(
                  listener: (context, state) {
                    if (state is UploadFileLoadingState) {
                      LoadingAnimation.show(context);
                    }
                    if (state is UploadFileSuccessState) {
                      LoadingAnimation.hide(context);
                      final fileUrl =
                          "https://api.todaystrends.site/externalFiles/${state.response.fileName}";
                      switch (state.key) {
                        case ImageMapperEnum.userImg:
                          uploadImage = fileUrl;
                          _updateUserImage(uploadImage!);
                          break;
                        case ImageMapperEnum.logoImg:
                          logoImage = fileUrl;
                          _updateLogoImage(logoImage!);
                          break;
                        case ImageMapperEnum.signature:
                          signatureImage = fileUrl;
                          _updateSignatureImage(signatureImage!);
                          break;
                        default:
                          break;
                      }
                    }
                    if (state is UploadFileErrorState) {
                      LoadingAnimation.hide(context);
                      ToastUtils.showErrorToast(state.error);
                    }
                  },
                ),
                BlocListener<StudentFormCubit, StudentFormState>(
                    listener: (context, state) {
                  if (state is StudentFormSuccessState) {
                    templateData = state.response.data;
                    templateFields = state.response.data.templateFields;
                    for (String field in templateFields) {
                      _controllers.putIfAbsent(
                          field, () => TextEditingController());
                    }
                    for (String field
                        in templateData!.templateBackFields ?? []) {
                      _backControllers.putIfAbsent(
                          field, () => TextEditingController());
                    }
                  }
                  if (state is AddStudentDetailsSuccessState) {
                    for (var controller in _controllers.values) {
                      controller.clear();
                    }
                    uploadImage = null;
                    _image = null;
                    _webViewController?.reload();
                    if (logoImage != null) {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        _updateLogoImage(logoImage!);
                      });
                    }
                    if (editableRecord != null) {
                      editableRecord = null;
                      SuccessDialog.show(context,
                          title: 'Student Updated',
                          message: 'Student details updated\nsuccessfully.');
                    } else {
                      SuccessDialog.show(context,
                          title: 'Student Added',
                          message: 'Student details added\nsuccessfully.');
                    }
                  }
                  if (state is AddStudentDetailsErrorState) {
                    ToastUtils.showErrorToast(state.error);
                  }
                })
              ],
              child: BlocBuilder<CreateOrderCubit, CreateOrderState>(
                builder: (context, state) {
                  if (state is CreateOrderRequestLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return BlocBuilder<StudentFormCubit, StudentFormState>(
                    builder: (context, state) {
                      if (state is StudentFormRequestLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is StudentFormErrorState) {
                        return Center(
                          child: Text(
                            state.error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (templateData != null) {
                        return _buildForm(state: state);
                      }
                      return const Center(child: Text(""));
                    },
                  );
                },
              ))),
    );
  }

  Widget _buildForm({required StudentFormState state}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Student ID Card Preview
        const SizedBox(
          height: 10,
        ),
        Container(
          width: templateData?.isPortrait == true ? 200 : double.maxFinite,
          height: templateData?.isPortrait == true ? 330 : 220,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: (value) {
              pageValue.value = value;
            },
            children: [
              RepaintBoundary(
                key: _frontKey,
                child: WebViewContainer(
                  url: templateData!.edittemplateimageUrl,
                  html: widget.args.frontHtml,
                  onControllerCreated: (controller) {
                    _webViewController = controller; // Store the controller
                    Future.delayed(const Duration(milliseconds: 300), () async {
                      _controllers.forEach((key, controller) {
                        if (controller.text.isNotEmpty) {
                          _updateWebViewTextByClassNAme(key, controller.text);
                        }
                      });
                      if (uploadImage != null) {
                        _updateUserImage(uploadImage!);
                      }
                      if (logoImage != null) {
                        _updateLogoImage(logoImage!);
                      }
                      if (signatureImage != null) {
                        _updateSignatureImage(signatureImage!);
                      }
                      frontPngBytes ??= await _captureImage(_frontKey);
                    });
                  },
                ),
              ),
              if (templateData?.edittemplateBackUrl != null)
                RepaintBoundary(
                  key: _backKey,
                  child: WebViewContainer(
                    url: templateData!.edittemplateBackUrl!,
                    html: widget.args.backHtml,
                    onControllerCreated: (controller) {
                      _backWebViewController =
                          controller; // Store the controller
                      Future.delayed(const Duration(milliseconds: 300),
                          () async {
                        _backControllers.forEach((key, controller) {
                          if (controller.text.isNotEmpty) {
                            _updateBackWebViewTextByClassNAme(
                                key, controller.text);
                          }
                        });
                        if (logoImage != null) {
                          _updateLogoImage(logoImage!);
                        }
                        if (signatureImage != null) {
                          _updateSignatureImage(signatureImage!);
                        }
                        backPngBytes ??= await _captureImage(_backKey);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),

        if (templateData?.edittemplateBackUrl != null)
          Align(
              alignment: Alignment.centerRight,
              child: StatefulBuilder(builder: (context, setState) {
                return GestureDetector(
                  onTap: () {
                    final currentPage = pageController.page?.toInt() ?? 0;
                    pageController.jumpToPage(currentPage == 0 ? 1 : 0);
                    setState(() {});
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Text(
                        pageController.page?.toInt() != 1
                            ? 'Back ->'
                            : '<- Front',
                        style: GoogleFonts.poppins(
                            color: AppColors.violetBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      )),
                );
              }))
        else
          const SizedBox(
            height: 10,
          ),

        ValueListenableBuilder(
            valueListenable: pageValue,
            builder: (context, value, child) {
              if (value == 0) {
                return _frontCardView(state);
              }
              return _backCardView(state);
            })
      ],
    );
  }

  Widget _backCardView(StudentFormState state) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF262626),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              for (var entry in _backControllers.entries)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: TextFormField(
                        controller: entry.value,
                        style: GoogleFonts.nunitoSans(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: entry.key,
                          hintStyle: GoogleFonts.nunitoSans(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (value) => value!.isEmpty
                            ? "This field cannot be empty"
                            : null,
                        onChanged: (value) {
                          // Update the WebView with the new text
                          _updateBackWebViewTextByClassNAme(entry.key, value);
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7653F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onPressed: () {
                  pageController.jumpTo(0);
                },
                child: Text(
                  "Save",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget captureUserImage() {
    return Opacity(
      opacity: templateData!.isUserImageAvailable ? 1 : 0.6,
      child: GestureDetector(
        onTap: () {
          if (templateData!.isUserImageAvailable) {
            FocusScope.of(context).unfocus();
            _showImagePicker(ImageMapperEnum.userImg);
          }
        },
        child: SizedBox(
          width: 90,
          child: Column(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFD9D9D9),
                    child: uploadImage != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: uploadImage!,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Icons.info,
                                  size: 25,
                                  color: Colors.white,
                                );
                              },
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _image != null
                            ? ClipOval(
                                child: Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : SvgPicture.asset('assets/icons/user_person.svg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF7653F6),
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 1.25,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Color(0xFFFAFAFA),
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x19B5B5B5),
                            blurRadius: 30,
                            offset: Offset(0, 5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.whiteColor,
                        size: 16,
                      ),
                    ),
                  )
                ],
              ),
              Text(
                'Add User Image',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.17,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget captureLogoImage() {
    return Opacity(
      opacity: templateData?.isLogoRequired == true ? 1 : 0.6,
      child: GestureDetector(
        onTap: () {
          if (templateData?.isLogoRequired == true) {
            FocusScope.of(context).unfocus();
            _showImagePicker(ImageMapperEnum.logoImg);
          }
        },
        child: Column(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFD9D9D9),
              child: logoImage != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: logoImage!,
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.info,
                            size: 25,
                            color: Colors.white,
                          );
                        },
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _logoImage != null
                      ? ClipOval(
                          child: Image.file(
                            _logoImage!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : SvgPicture.asset('assets/icons/logo.svg'),
            ),
            Text(
              'Add Logo',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.17,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget captureSignatureImage() {
    return Opacity(
      opacity: templateData?.isSignatureRequired == true ? 1 : 0.6,
      child: GestureDetector(
        onTap: () {
          if (templateData?.isSignatureRequired == true) {
            FocusScope.of(context).unfocus();
            _showImagePicker(ImageMapperEnum.signature);
          }
        },
        child: Column(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFD9D9D9),
              child: signatureImage != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: signatureImage!,
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.info,
                            size: 25,
                            color: Colors.white,
                          );
                        },
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _signatureImage != null
                      ? ClipOval(
                          child: Image.file(
                            _signatureImage!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : SvgPicture.asset('assets/icons/signature.svg'),
            ),
            Text(
              'Add Signature',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.17,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _frontCardView(StudentFormState state) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF262626),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [
                  captureUserImage(),
                  captureLogoImage(),
                  captureSignatureImage()
                ],
              ),
              const SizedBox(height: 15),
              ..._buildDynamicFields(),
              const SizedBox(height: 20),
              if (state is AddStudentDetailsLoadingState)
                const LoadingAnimation()
              else if (editableRecord != null &&
                  editableRecord!.data.isNotEmpty)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7653F6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                  onPressed: _updateRecord,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_box_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Update Details",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7653F6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (templateData?.xlFileUrl != null) {
                              launchUrl(Uri.parse(templateData!.xlFileUrl!),
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/page.svg',
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Download",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7653F6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (templateData!.isLogoRequired &&
                                  logoImage == null) {
                                ToastUtils.showErrorToast(
                                    'Add Logo image first');
                                return;
                              }
                              if (templateData!.isSignatureRequired &&
                                  signatureImage == null) {
                                ToastUtils.showErrorToast('Add Signatue first');
                                return;
                              }

                              _pickExcelFile();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/page.svg',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Upload",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7653F6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                        onPressed: _addNewEntry,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_box_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Add Details",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFields() {
    List<Widget> fieldWidgets = [];
    for (int i = 0; i < templateFields.length; i++) {
      if (i == 0) {
        fieldWidgets.add(_buildTextFieldWithLabel(templateFields[i], i));
        fieldWidgets.add(const SizedBox(height: 8));
      } else if (i == 1 && templateFields.length > 2) {
        fieldWidgets.add(
          Row(
            children: [
              Expanded(child: _buildTextFieldWithLabel(templateFields[i], i)),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < templateFields.length
                    ? _buildTextFieldWithLabel(templateFields[i + 1], i + 1)
                    : Container(),
              ),
            ],
          ),
        );
        i++;
        fieldWidgets.add(const SizedBox(height: 8));
      } else {
        fieldWidgets.add(_buildTextFieldWithLabel(templateFields[i], i));
        fieldWidgets.add(const SizedBox(height: 8));
      }
    }
    return fieldWidgets;
  }

  Widget _buildTextFieldWithLabel(String fieldName, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            fieldName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: TextFormField(
            controller: _controllers[fieldName],
            style: GoogleFonts.nunitoSans(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: fieldName,
              hintStyle: GoogleFonts.nunitoSans(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) =>
                value!.isEmpty ? "This field cannot be empty" : null,
            onChanged: (value) {
              // Update the WebView with the new text
              _updateWebViewText(index, value);
            },
          ),
        ),
      ],
    );
  }

  void _autofillData() {
    if (editableRecord != null && editableRecord!.data.isNotEmpty) {
      editableRecord!.data.entries.forEach((entry) {
        if (entry.key == 'id') return;
        if (entry.key.startsWith('http')) {
          _updateUserImage(entry.value);
          uploadImage = entry.value;
        } else {
          if (templateData?.templateFields.contains(entry.key) == true) {
            _controllers[entry.key] = TextEditingController(text: entry.value);
            _updateWebViewTextByClassNAme(entry.key, entry.value);
          }
          if (templateData?.templateBackFields?.contains(entry.key) == true) {
            _backControllers[entry.key] =
                TextEditingController(text: entry.value);
            _updateBackWebViewTextByClassNAme(entry.key, entry.value);
          }
        }
      });
      if (editableRecord!.logoUrl != null) {
        logoImage = editableRecord!.logoUrl;
        _updateLogoImage(editableRecord!.logoUrl!);
      }
      if (editableRecord!.signatureUrl != null) {
        signatureImage = editableRecord!.signatureUrl;
        _updateSignatureImage(editableRecord!.signatureUrl!);
      }
    }
    setState(() {});
  }

  void _updateWebViewText(int dataId, String text) {
    if (_webViewController == null) return;

    final className = templateData!.templateFields[dataId];
    // JavaScript to update the text of the element with the matching data-id
    _updateWebViewTextByClassNAme(className, text);
  }

  void _updateWebViewTextByClassNAme(String className, String text) {
    if (_webViewController == null) return;

    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="$className"]');
        if (element) {
          element.innerText = "$text";
        }
      })();
    """;

    _webViewController!.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
  }

  void _updateBackWebViewTextByClassNAme(String className, String text) {
    if (_backWebViewController == null) return;

    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="$className"]');
        if (element) {
          element.innerText = "$text";
        }
      })();
    """;

    _backWebViewController!.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
  }

  void _updateUserImage(String newUrl) {
    if (_webViewController == null) return;

    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="https://api.todaystrends.site/externalFiles/userpic.png"]');
        if (element) {
          element.src = "$newUrl";
        }
      })();
    """;

    _webViewController!.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
  }

  void _updateLogoImage(String newUrl) {
    if (_webViewController == null) return;

    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="https://api.todaystrends.site/externalFiles/logo.png"]');
        if (element) {
          element.src = "$newUrl";
        }
      })();
    """;

    _webViewController?.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
    // if (_backWebViewController != null) {
    _backWebViewController?.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
    // }
  }

  void _updateSignatureImage(String newUrl) {
    if (_webViewController == null) return;

    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="https://api.todaystrends.site/externalFiles/signature.png"]');
        if (element) {
          element.src = "$newUrl";
        }
      })();
    """;

    _webViewController?.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
    // if (_backWebViewController != null) {
    _backWebViewController?.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
    // }
  }
}

class WebViewContainer extends StatefulWidget {
  final String url;
  final String? html;
  final Function(WebViewController)?
      onControllerCreated; // Callback to pass the controller

  const WebViewContainer(
      {super.key, required this.url, this.onControllerCreated, this.html});

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late WebViewController _controller;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    print("Initializing WebView with URL: ${widget.url}");
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          print("Page started: $url");
          setState(() => _isValid = true);
        },
        onPageFinished: (url) {
          _controller.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);

            document.body.style.overflow = 'hidden';
            document.documentElement.style.overflow = 'hidden';
          ''');
          setState(() => _isValid = true);
        },
        onWebResourceError: (error) {
          setState(() => _isValid = false);
        },
      )).catchError((e) {
        print("Load request failed: $e");
        setState(() => _isValid = false);
      });

    if (widget.html != null) {
      _controller.loadHtmlString(widget.html!);
    } else {
      _controller.loadRequest(Uri.parse(widget.url));
    }

    // Call the callback to pass the controller to the parent
    if (widget.onControllerCreated != null) {
      widget.onControllerCreated!(_controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
