import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pride/components/back_button.dart';
import 'package:pride/domain/models/edit_template_models/edit_template_request.dart';
import 'package:pride/domain/models/student_form_models/order_pre_data.dart';
import 'package:pride/domain/models/student_form_models/student_form_response.dart';
import 'package:pride/presentation/bloc/create_order_bloc/create_order_cubit.dart';
import 'package:pride/presentation/bloc/update_template_bloc/update_template_cubit.dart';
import 'package:pride/presentation/bloc/update_template_bloc/update_template_state.dart';
import 'package:pride/presentation/bloc/upload_file_bloc/upload_file_cubit.dart';
import 'package:pride/presentation/bloc/upload_file_bloc/upload_file_state.dart';
import 'package:pride/presentation/screen/order_details_screen/delete_details_confirmation_dialog.dart';
import 'package:pride/presentation/screen/order_details_screen/order_success_dialog.dart';
import 'package:pride/presentation/screen/order_details_screen/preview_container.dart';
import 'package:pride/presentation/screen/order_details_screen/util_buttons.dart';
import 'package:pride/theme/app_colors.dart';
import 'package:pride/utils/loading_animation.dart';
import 'package:pride/utils/vl_toast.dart';

import '../../../data/data_sources/local/database_helper.dart';
import '../../../domain/models/create_order_models/create_order_request.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_request.dart';
import '../../../navigation/page_routes.dart';
import '../../bloc/create_order_bloc/create_order_state.dart';

class OrderDetailsArguments {
  final String schoolId;
  final TemplateData template;
  final String orderType;
  final String? htmlFront;
  final String? htmlBack;
  final Uint8List? frontThumbnailImage;
  final Uint8List? backThumbnailImage;

  OrderDetailsArguments(
      {required this.schoolId,
      required this.template,
      required this.orderType,
      required this.htmlFront,
      required this.htmlBack,
      required this.frontThumbnailImage,
      required this.backThumbnailImage});
}

class OrderDetailsScreen extends StatefulWidget {
  final OrderDetailsArguments args;

  const OrderDetailsScreen(
      {super.key,
      required this.args}); // 'array' for manual data, 'excel' for excel upload

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<OrderPreData> _orderDataList = [];
  Future<void> _showClearAllConfirmationDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.maxFinite,
                    height: 50,
                    decoration: const ShapeDecoration(
                      color: AppColors.violetBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'Action Required',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Are you sure you want to clear all student records?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context, false),
                          icon: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          label: Text(
                            'Not Now',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, true),
                          icon: const Icon(
                            Icons.cleaning_services_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Clear',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 2,
                              color: AppColors.whiteColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.violetBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      final tableName =
          widget.args.orderType == 'excel' ? 'excel_orders' : 'orders';
      await DatabaseHelper.instance.clearTableWithTemplateId(
        tableName,
        templateId: widget.args.template.id,
      );
      setState(() => _orderDataList.clear());
    }
  }

  bool _isLoading = false;

  final picker = ImagePicker();

  /// For manual entry submission: collects form data and stores in DB (table: orders)
  Future<void> _submitForm({String? templateId}) async {
    CreateOrderRequest request = CreateOrderRequest(
      schoolId: widget.args.schoolId,
      templateId: templateId ?? widget.args.template.id,
      orderType: 'array',
      orderData: _orderDataList,
    );

    context.read<CreateOrderCubit>().createOrder(request);

    print('createOrderResponse: ${jsonEncode(request.toJson())}');
  }

  Future<void> _showImagePicker(OrderPreData order) async {
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

                  _pickImage(ImageSource.gallery, order);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Capture from Camera'),
                onTap: () {
                  Navigator.maybePop(context);

                  _pickImage(ImageSource.camera, order);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    OrderPreData order,
  ) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile =
          await ImageCropper().cropImage(sourcePath: pickedFile.path);
      if (croppedFile != null) {
        _uploadImage(File(croppedFile.path), order);
      }
    }
  }

  void _uploadImage(
    File imageFile,
    OrderPreData order,
  ) {
    final request = ExternalUploadFileRequest(file: imageFile);
    context
        .read<CreateOrderCubit>()
        .updatePersonImage(request, orderPreData: order);
  }

  Future<void> _submitExcelFile({String? templateId}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      // final excelRecords = await db.query('excel_orders');

      // if (excelRecords.isNotEmpty == true) {
      //   List<Map<String, dynamic>> excelData = [];
      //   for (var record in excelRecords) {
      //     var decoded = json.decode(record['data'] as String);
      //     if (decoded is List) {
      //       excelData.addAll(decoded.map((e) => e as Map<String, dynamic>));
      //     } else if (decoded is Map<String, dynamic>) {
      //       excelData.add(decoded);
      //     }
      //   }

      // CreateOrderRequest request = CreateOrderRequest(
      //   schoolId: widget.args.schoolId,
      //   templateId: templateId ?? widget.args.template.id,
      //   orderType: 'excelfile',
      //   orderData: excelData,
      // );

      //   context.read<CreateOrderCubit>().createOrder(request);

      //   DatabaseHelper.instance.clearTable('excel_orders');

      //   // setState(() {
      //   //   excelData.clear();
      //   // });
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text("No Excel Data Found!"),
      //       duration: Duration(seconds: 3),
      //     ),
      //   );
      // }
    } catch (e, stackTrace) {}
  }

  void _showLoadingDialog() {
    if (!_isLoading) {
      _isLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
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
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final String tableName =
        widget.args.orderType == 'excel' ? 'excel_orders' : 'orders';
    final orders = await DatabaseHelper.instance
        .getOrders(widget.args.template.id, tableName: tableName);
    // List<Map<String, dynamic>> allEntries = [];
    // for (var order in orders) {
    //   var decoded = json.decode(order['data']);
    //   if (decoded is List) {
    //     for (var row in decoded) {
    //       if (row is Map<String, dynamic>) {
    //         row['id'] = order['id'];
    //         allEntries.add(row);
    //       }
    //     }
    //   } else if (decoded is Map<String, dynamic>) {
    //     decoded['id'] = order['id'];
    //     allEntries.add(decoded);
    //   }
    // }
    setState(() {
      _orderDataList = orders.map((it) => OrderPreData.fromJson(it)).toList();
    });
  }

  Future<void> _deleteOrder(int id) async {
    final String tableName =
        widget.args.orderType == 'excel' ? 'excel_orders' : 'orders';
    context
        .read<CreateOrderCubit>()
        .deleteStudentDetails(id, tableName: tableName);
  }

  Future<void> _editOrder(Map<String, dynamic> order) async {
    await showDialog(
      context: context,
      builder: (context) => EditOrderDialog(
        order: order,
        orderType: widget.args.orderType,
        onSave: (updatedOrder) async {
          final String tableName =
              widget.args.orderType == 'excel' ? 'excel_orders' : 'orders';
          await updateOrder(updatedOrder, tableName);
          await _fetchOrders();
        },
      ),
    );
  }

  Future<void> updateOrder(
      Map<String, dynamic> updatedOrder, String tableName) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = updatedOrder['id'];
      updatedOrder.remove('id'); // Remove id from the data to be updated
      final String jsonData = json.encode(updatedOrder);
      await db.update(
        tableName,
        {'data': jsonData},
        where: 'id = ?',
        whereArgs: [id],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order Updated..."),
          duration: Duration(seconds: 2),
        ),
      );
      print("Successfully updated order $id in $tableName table");
    } catch (e) {
      print("Error updating order in $tableName table: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update order"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "All Details",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0XFF262626),
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: SLBackButton(),
          ),
          backgroundColor: Colors.white,
          actions: [
            if (_orderDataList.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.cleaning_services_rounded,
                    color: Color(0xFF7653F6)),
                onPressed: _showClearAllConfirmationDialog,
              ),
          ],
        ),
        body: _orderDataList.isEmpty
            ? const Center(child: Text('No entries found.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _orderDataList.length,
                itemBuilder: (context, index) {
                  final order = _orderDataList[index];
                  final displayData = Map<String, dynamic>.from(order.data)
                    ..remove('id')
                    ..remove(
                        'https://api.todaystrends.site/externalFiles/userpic.png');
                  final data = Map<String, dynamic>.from(order.data)
                    ..remove('id');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.black.withOpacity(0.26),
                            offset: const Offset(0, 2),
                            blurRadius: 5,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            decoration: const BoxDecoration(
                              color: Color(0XFF7653F6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.args.template.isUserImageAvailable)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      _showImagePicker(order);
                                    },
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage: order.data[
                                                      'https://api.todaystrends.site/externalFiles/userpic.png'] !=
                                                  null
                                              ? CachedNetworkImageProvider(order
                                                      .data[
                                                  'https://api.todaystrends.site/externalFiles/userpic.png'])
                                              : null,
                                          child: order.data[
                                                      'https://api.todaystrends.site/externalFiles/userpic.png'] !=
                                                  null
                                              ? const Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 34,
                                                  color: Colors.grey,
                                                )
                                              : SvgPicture.asset(
                                                  'assets/icons/user_person.svg'),
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
                                                  strokeAlign: BorderSide
                                                      .strokeAlignOutside,
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
                                  ),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: displayData.entries
                                      .toList()
                                      .sublist(
                                          0,
                                          displayData.length >= 3
                                              ? 3
                                              : displayData.length)
                                      .map((entry) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: RichText(
                                        maxLines: 2,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${entry.key}: ',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0XFF555555),
                                              ),
                                            ),
                                            TextSpan(
                                              text: entry.value ?? 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF262626),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  UtilsButton(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) => Material(
                                                  color: Colors.transparent,
                                                  child: Center(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        spacing: 20,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                'Preview',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .black,
                                                                  ))
                                                            ],
                                                          ),
                                                          Flexible(
                                                            child: ListView(
                                                              shrinkWrap: true,
                                                              children: [
                                                                Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width: widget.args.template.isPortrait ==
                                                                            true
                                                                        ? 200
                                                                        : 330,
                                                                    height: widget.args.template.isPortrait ==
                                                                            true
                                                                        ? 300
                                                                        : 220,
                                                                    child:
                                                                        PreviewWebViewContainer(
                                                                      url: widget
                                                                          .args
                                                                          .template
                                                                          .edittemplateimageUrl,
                                                                      html: widget
                                                                          .args
                                                                          .htmlFront,
                                                                      data: order
                                                                          .toJson(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                if (widget
                                                                        .args
                                                                        .template
                                                                        .edittemplateBackUrl !=
                                                                    null)
                                                                  Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width: widget.args.template.isPortrait ==
                                                                              true
                                                                          ? 200
                                                                          : 330,
                                                                      height: widget.args.template.isPortrait ==
                                                                              true
                                                                          ? 300
                                                                          : 220,
                                                                      child:
                                                                          PreviewWebViewContainer(
                                                                        url: widget
                                                                            .args
                                                                            .template
                                                                            .edittemplateBackUrl!,
                                                                        html: widget
                                                                            .args
                                                                            .htmlBack,
                                                                        data: order
                                                                            .toJson(),
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                      },
                                      label: 'Preview'),
                                  UtilsButton(
                                      onTap: () {
                                        Navigator.pop(context, order);
                                      },
                                      label: 'Edit'),
                                  GestureDetector(
                                    onTap: () {
                                      DeleteDetailsConfirmationDialog.show(
                                        context,
                                        onConfirm: () {
                                          _deleteOrder(order.id);
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0XFF262626),
                                        fontWeight: FontWeight.w700,
                                        height: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocListener<UpdateTemplateCubit, UpdateTemplateState>(
            listener: (context, state) {
              if (state is UpdateTemplateLoadingState) {
                LoadingAnimation.show(context);
              }
              if (state is UpdateTemplateErrorState) {
                LoadingAnimation.hide(context);
                ToastUtils.showErrorToast(state.error);
              }
              if (state is UpdateTemplateSuccessState) {
                LoadingAnimation.hide(context);
                if (widget.args.orderType == 'array') {
                  _submitForm(templateId: state.response.templateId);
                } else if (widget.args.orderType == 'excel') {
                  _submitExcelFile(templateId: state.response.templateId);
                }
              }
            },
            child: BlocConsumer<CreateOrderCubit, CreateOrderState>(
              listener: (context, state) {
                if (state is CreateOrderSuccessState) {
                  LoadingAnimation.hide(context);
                  // Optionally, clear previous manual entries by deleting from 'orders'
                  DatabaseHelper.instance.clearTableWithTemplateId('orders',
                      templateId: widget.args.template.id);
                  // setState(() {
                  _orderDataList.clear();
                  // });
                  // Navigator.of(
                  //   context,
                  // ).popUntil((route) => route.settings.name == PageRoutes.home);
                  // ToastUtils.showSuccessToast('Order placed successfully');

                  OrderSuccessDialog.show(context);
                }
                if (state is DeleteStudentRecordLoadingState ||
                    state is CreateOrderRequestLoadingState ||
                    state is UpdateImageLoadingState) {
                  LoadingAnimation.show(context);
                }
                if (state is DeleteStudentRecordErrorState) {
                  LoadingAnimation.hide(context);
                  ToastUtils.showErrorToast(state.error);
                }
                if (state is UpdateImageSuccessState) {
                  LoadingAnimation.hide(context);
                  _fetchOrders();
                }
                if (state is DeleteStudentRecordSuccessState) {
                  LoadingAnimation.hide(context);
                  ToastUtils.showSuccessToast(
                      "Deleted Student record Successfully");
                  _fetchOrders();
                }
                if (state is UpdateImageErrorState) {
                  LoadingAnimation.hide(context);
                  ToastUtils.showErrorToast(state.error);
                }
                if (state is CreateOrderErrorState) {
                  LoadingAnimation.hide(context);
                  ToastUtils.showErrorToast(
                      state.error ?? 'Something went wrong');
                }
              },
              builder: (context, state) {
                if (_orderDataList.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ElevatedButton(
                  onPressed: () async {
                    if (widget.args.template.isUserImageAvailable) {
                      final isValid = _orderDataList
                          .every((element) => element.hasUserImage == true);

                      if (!isValid) {
                        ToastUtils.showErrorToast(
                            'Please add user image for all records');
                        return;
                      }
                    }

                    if (widget.args.htmlFront != null) {
                      final Directory directory =
                          await getApplicationDocumentsDirectory();
                      final File file =
                          File('${directory.path}/modified_template.html');

                      await file.writeAsString(widget.args.htmlFront!);
                      File? backFile;
                      if (widget.args.htmlBack != null) {
                        backFile = File(
                            '${directory.path}/modified_template_back.html');
                        await backFile.writeAsString(widget.args.htmlBack!);
                      }
                      if (await file.exists()) {
                        context
                            .read<UpdateTemplateCubit>()
                            .updateCustomTemplate(
                              request: EditTemplateRequest(
                                  template: file,
                                  templateBack: backFile,
                                  frontImage: widget.args.frontThumbnailImage!,
                                  backImage: widget.args.backThumbnailImage),
                              schoolId: widget.args.schoolId,
                            );
                      }
                    } else {
                      if (widget.args.orderType == 'array') {
                        await _submitForm();
                      } else if (widget.args.orderType == 'excel') {
                        await _submitExcelFile();
                      }
                    }
                  },
                  child: const Text("Place Order",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7653F6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class EditOrderDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final String orderType;
  final Function(Map<String, dynamic>) onSave;

  const EditOrderDialog({
    Key? key,
    required this.order,
    required this.orderType,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditOrderDialogState createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final picker = ImagePicker();
  String? _uploadImage;
  Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> _updatedOrder = {};

  @override
  void initState() {
    super.initState();
    _updatedOrder = Map<String, dynamic>.from(widget.order);
    _uploadImage =
        widget.order['https://api.todaystrends.site/externalFiles/userpic.png'];
    _initializeControllers();
  }

  void _initializeControllers() {
    widget.order.forEach((key, value) {
      if (key != 'id' &&
          key != 'https://api.todaystrends.site/externalFiles/userpic.png') {
        _controllers[key] =
            TextEditingController(text: value?.toString() ?? '');
      }
    });
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
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageFile(_image!);
    }
  }

  void _uploadImageFile(File imageFile) {
    final request = ExternalUploadFileRequest(file: imageFile);
    context.read<UploadFileCubit>().fetchUploadedFiles(request: request);
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _controllers.forEach((key, controller) {
        _updatedOrder[key] = controller.text;
      });
      if (_uploadImage != null) {
        _updatedOrder[
                'https://api.todaystrends.site/externalFiles/userpic.png'] =
            _uploadImage;
      } else {
        _updatedOrder
            .remove('https://api.todaystrends.site/externalFiles/userpic.png');
      }
      widget.onSave(_updatedOrder);
      Navigator.maybePop(context);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Order",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF262626),
                  ),
                ),
                const SizedBox(height: 16),
                BlocListener<UploadFileCubit, UploadFileState>(
                  listener: (context, state) {
                    if (state is UploadFileSuccessState) {
                      setState(() {
                        _uploadImage =
                            "https://api.todaystrends.site/externalFiles/${state.response.fileName}";
                      });
                    } else if (state is UploadFileErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Failed to upload image: ${state.error}"),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: GestureDetector(
                    onTap: _showImagePicker,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      child: ClipOval(
                        child: _image != null
                            ? Image.file(
                                _image!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : _uploadImage != null
                                ? Image.network(
                                    _uploadImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.white,
                                    ),
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
                const SizedBox(height: 16),
                ..._controllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: const Color(0XFF555555),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: entry.value,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: entry.key,
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "This field cannot be empty"
                              : null,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7653F6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
