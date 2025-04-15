import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/data_sources/local/database_helper.dart';
import '../../../data/data_sources/local/preference_utils.dart';
import '../../../domain/models/create_order_models/create_order_request.dart';
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
import 'package:file_picker/file_picker.dart';

class StudentIDForm extends StatefulWidget {
  final String id;
  final String? imageUrl;
  final bool? isPortait;
  const StudentIDForm({Key? key, required this.id, required this.imageUrl, required this.isPortait}) : super(key: key);

  @override
  _StudentIDFormState createState() => _StudentIDFormState();
}

class _StudentIDFormState extends State<StudentIDForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final picker = ImagePicker();
  final Map<String, TextEditingController> _controllers = {};
  List<String> templateFields = [];
  List<Map<String, dynamic>> _orderDataList = [];
  String studentId = "";
  String? uploadImage;

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
    context.read<StudentFormCubit>().submitStudentForm(
        StudentFormRequest(id: widget.id));
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
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Capture from Camera'),
                onTap: () {
                  Navigator.pop(context);
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
      setState(() {
        _image = File(pickedFile.path);
      });

      _uploadImage(_image!);
    }
  }

  void _uploadImage(File imageFile) {
    final request = ExternalUploadFileRequest(file: imageFile);
    context.read<UploadFileCubit>().fetchUploadedFiles(request: request);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }


// Add the uploadImage URL
      if (uploadImage?.isNotEmpty == true) {
        formData['https://idcardprojectapis.logicaldottech.com/externalFiles/userpic.png'] =
            uploadImage;
      }
      _orderDataList.add(formData);


      CreateOrderRequest request = CreateOrderRequest(
        schoolId: studentId,
        templateId: widget.id,
        orderType: 'array',

        orderData: _orderDataList,
      );

      context.read<CreateOrderCubit>().createOrder(request);
      print('createOrderResponse: ${jsonEncode(request.toJson())}');
    }
  }
  Future<void> _addNewEntry() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }
      // Add the uploadImage URL if available
      if (uploadImage?.isNotEmpty == true) {
        formData['https://idcardprojectapis.logicaldottech.com/externalFiles/userpic.png'] = uploadImage;
      }
      // Convert map to JSON string
      String jsonData = json.encode(formData);

      // Store in 'orders' table for manual entries
      final db = await DatabaseHelper.instance.database;
      await db.insert('orders', {'data': jsonData});
      _orderDataList.add(formData);
    }

    setState(() {
      for (var controller in _controllers.values) {
        controller.clear();
      }
      uploadImage = null;
      _image = null;
    });
  }



  void _clearData() {
    setState(() {
      for (var controller in _controllers.values) {
        controller.clear();
      }
      _orderDataList.clear();
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

        String jsonData = json.encode(sheetData);
        print("Excel JSON Data: $jsonData");

        // Store in a separate table 'excel_orders' for Excel uploads.
        final db = await DatabaseHelper.instance.database;
        // Delete previous excel orders to replace with new data.
        await db.delete('excel_orders');
        final int dbResult = await db.insert('excel_orders', {'data': jsonData});
        print("Insert result: $dbResult");

        if (dbResult > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File Uploaded Successfully!"),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pushNamed(
            PageRoutes.orderDetailsScreen,
            arguments: {
              'schoolId': studentId,
              'templateId': widget.id,
              'orderType': 'excel',
            },
          );
          debugPrint("Excel data stored successfully in the DB.");
        } else {
          debugPrint("Failed to store Excel data in the DB.");
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFC4C4C4),
      appBar: AppBar(

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Handle back navigation
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: BlocConsumer<CreateOrderCubit, CreateOrderState>(
        listener: (context, state) {
          if (state is CreateOrderSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Order Submitted Successfully!")),
            );
            Navigator.of(context, rootNavigator: true).pushNamed(
                PageRoutes.home);
          } else if (state is CreateOrderErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.toString(),
                  style: const TextStyle(color: Colors.red))),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateOrderRequestLoadingState) {
            return const Center();
          }

          return BlocBuilder<StudentFormCubit, StudentFormState>(
            builder: (context, state) {
              if (state is StudentFormLoadingState) {
                return const Center();
              } else if (state is StudentFormSuccessState) {
                templateFields = state.response.data.templateFields;
                // uploadImage = "https://idcardprojectapis.logicaldottech.com/externalFiles/${state.response.data.fileName}";
                for (String field in templateFields) {
                  _controllers.putIfAbsent(
                      field, () => TextEditingController());
                }
                return _buildForm();
              } else if (state is StudentFormErrorState) {
                return Center(child: Text(state.error.toString(),
                    style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text(""));
            },
          );
        },
      ),
    );
  }




  Widget _buildForm() {
    return Column(
      children: [
        // Student ID Card Preview (WebViewContainer from the original code)
        BlocBuilder<UploadFileCubit, UploadFileState>(
          builder: (context, state) {
            if (state is UploadFileLoadingState) {
              return const Center();
            } else if (state is UploadFileSuccessState) {
              uploadImage =
              "https://idcardprojectapis.logicaldottech.com/externalFiles/${state.response.fileName}";
            } else if (state is UploadFileErrorState) {

            }
            return Center();
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: widget.isPortait == true ? 200 : 330,
          height: widget.isPortait == true ? 300 : 220,
          child: WebViewContainer(url: widget?.imageUrl ?? ""),
        ),
        Positioned(
          top: -20, // Moves the icon up to overlap the boundary

          right: 40,
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed(
                  PageRoutes.orderDetailsScreen,
                  arguments: {
                    'schoolId': studentId,
                    'templateId': widget.id,
                    'orderType': 'array',
                  },
                );
              },
              child: Container(
                height: 40,
                width: 80,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // White background for the eye icon
                ),
                child: const Icon(
                  Icons.remove_red_eye, // Eye icon
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Dark Background Container
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF262626), // Matches the dark background in the screenshot
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Profile Image Upload Section
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImagePicker(),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800], // Matches the grey circle in the screenshot
                        child: ClipOval(
                          child: _image != null
                              ? Image.file(
                            _image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dynamic Input Fields
                  ..._buildDynamicFields(),

                  const SizedBox(height: 20),


                  // Add Student Details Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center, // Keeps the row size minimal
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7653F6), // Purple background color
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Added horizontal padding
                        ),
                        onPressed: _addNewEntry,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // Ensures the row doesn't stretch
                          children: [
                            Icon(
                              Icons.add_comment, // Icon for add button
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8), // Spacing between icon and text
                            Text(
                              "Add Student Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10), // Spacing between buttons
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7653F6), // Purple background color
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Added horizontal padding
                        ),
                        onPressed: (){
                          _pickExcelFile();
                         // Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.orderDetailsScreen);


                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // Ensures the row doesn't stretch
                          children: [
                            Icon(
                              Icons.book, // Icon for submit button
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8), // Spacing between icon and text
                            Text(
                              "",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),





                ],
              ),
            ),
          ),
        ),
        // Eye Icon Positioned at the Top Center

      ],
    );
  }

// Helper method to build dynamic fields with the desired layout
  List<Widget> _buildDynamicFields() {
    List<Widget> fieldWidgets = [];
    for (int i = 0; i < templateFields.length; i++) {
      if (i == 0) {
        // First field (e.g., "Full Name") should be full-width
        fieldWidgets.add(_buildTextFieldWithLabel(templateFields[i]));
        fieldWidgets.add(const SizedBox(height: 10));
      } else if (i == 1 && templateFields.length > 2) {
        // Second and third fields (e.g., "Roll Number" and "Birth Date") should be side by side
        fieldWidgets.add(
          Row(
            children: [
              Expanded(child: _buildTextFieldWithLabel(templateFields[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < templateFields.length
                    ? _buildTextFieldWithLabel(templateFields[i + 1])
                    : Container(), // Empty container if there's no third field
              ),
            ],
          ),
        );
        i++; // Skip the next field since we already added it
      } else {
        // Any additional fields after the first three should be full-width
        fieldWidgets.add(_buildTextFieldWithLabel(templateFields[i]));
        fieldWidgets.add(const SizedBox(height: 10));
      }
    }
    return fieldWidgets;
  }

// Updated method to build a text field with a label above it
  Widget _buildTextFieldWithLabel(String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName, // Uppercase label as in the screenshot
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: TextFormField(
            controller: _controllers[fieldName],
            style: const TextStyle(color: Colors.black), // Black text for input
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white, // White background as in the screenshot
              hintText: fieldName,
              hintStyle: const TextStyle(color: Colors.grey),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) => value!.isEmpty ? "This field cannot be empty" : null,
          ),
        ),
      ],
    );
  }
}

class WebViewContainer extends StatefulWidget {
  final String url;
  final VoidCallback? onTap; // Add onTap callback

  const WebViewContainer({required this.url, this.onTap});

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

          setState(() => _isValid = true);
        },
        onWebResourceError: (error) {

          setState(() => _isValid = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url)).catchError((e) {
        print("Load request failed: $e");
        setState(() => _isValid = false);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller)


      ],
    );
  }
}

