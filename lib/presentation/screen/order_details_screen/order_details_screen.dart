import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/presentation/bloc/create_order_bloc/create_order_cubit.dart';

import '../../../data/data_sources/local/database_helper.dart';
import '../../../domain/models/create_order_models/create_order_request.dart';
import '../../../navigation/page_routes.dart';
import '../../bloc/create_order_bloc/create_order_state.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String? schoolId;
  final String? templateId;
  final String? orderType; // 'array' for manual data, 'excel' for excel upload

  const OrderDetailsScreen({
    Key? key,
    required this.schoolId,
    required this.templateId,
    required this.orderType,
  }) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Map<String, dynamic>> _orderDataList = [];
  bool _isLoading = false;

  /// For manual entry submission: collects form data and stores in DB (table: orders)
  Future<void> _submitForm() async {
    CreateOrderRequest request = CreateOrderRequest(
      schoolId: widget.schoolId ?? "",
      templateId: widget.templateId ?? "",
      orderType: 'array',
      orderData: _orderDataList,
    );

    context.read<CreateOrderCubit>().createOrder(request);

    // Optionally, clear previous manual entries by deleting from 'orders'
    await DatabaseHelper.instance.deleteDatabaseFile(tableName: 'orders');
    setState(() {
      _orderDataList.clear();
    });
    print('createOrderResponse: ${jsonEncode(request.toJson())}');
  }

  Future<void> _submitExcelFile() async {
    try {
      final db = await DatabaseHelper.instance.database;
      // Fetch all records from the excel_orders table.
      final excelRecords = await db.query('excel_orders');

      if (excelRecords.isNotEmpty) {
        List<Map<String, dynamic>> excelData = [];
        // Combine all stored data. If there are multiple records, add them together.
        for (var record in excelRecords) {
          var decoded = json.decode(record['data'] as String);
          if (decoded is List) {
            excelData.addAll(decoded.map((e) => e as Map<String, dynamic>));
          } else if (decoded is Map<String, dynamic>) {
            excelData.add(decoded);
          }
        }



        // Create the order request using only the generated Excel file.
        CreateOrderRequest request = CreateOrderRequest(
          schoolId: widget.schoolId ?? "",
          templateId: widget.templateId ?? "",
          orderType: 'excelfile',
          orderData:  excelData// Only sending the file path as orderFile.
        );

        context.read<CreateOrderCubit>().createOrder(request);

        // Clear the excel_orders table after successful submission.
        await DatabaseHelper.instance.clearTable('excel_orders');


        setState(() {
          excelData.clear();
        });



      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Excel Data Found!"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong during Excel submission!"),
          duration: Duration(seconds: 3),
        ),
      );
    }
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
      Navigator.of(context, rootNavigator: true).pop();
      _isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  /// Fetch orders from the DB.
  /// Chooses table based on orderType: 'excel' reads from 'excel_orders', otherwise 'orders'.
  Future<void> _fetchOrders() async {
    final String tableName = widget.orderType == 'excel' ? 'excel_orders' : 'orders';
    final orders = await DatabaseHelper.instance.getOrders(tableName: tableName);
    List<Map<String, dynamic>> allEntries = [];
    for (var order in orders) {
      var decoded = json.decode(order['data']);
      if (decoded is List) {
        // Excel upload: decoded JSON is a list of rows
        for (var row in decoded) {
          if (row is Map<String, dynamic>) {
            row['id'] = order['id'];
            allEntries.add(row);
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        // Manual entry: decoded JSON is a single map
        decoded['id'] = order['id'];
        allEntries.add(decoded);
      }
    }
    setState(() {
      _orderDataList = allEntries;
    });
  }

  Future<void> _deleteOrder(int id) async {
    // You can decide to delete from both tables if needed or based on orderType
    await DatabaseHelper.instance.deleteOrder(id);
    _fetchOrders(); // Refresh the list after deletion
  }


  void deleteOrder(String orderId, String orderType) {
    if (orderType == "orders") {
      deleteFromOrdersTable(orderId);
    } else if (orderType == "excel_orders") {
      deleteFromExcelOrdersTable(orderId);
    } else {
      print("Invalid order type");
    }
  }

  void deleteFromOrdersTable(String orderId) {
    // Call API or database query to delete order from orders table
    print("Deleting order from orders table: $orderId");
    // Refresh UI or state after deletion
  }

  void deleteFromExcelOrdersTable(String orderId) {
    // Call API or database query to delete order from excel_orders table
    print("Deleting order from excel_orders table: $orderId");
    // Refresh UI or state after deletion
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "All Details",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color(0XFF262626),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Handle back navigation
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: _orderDataList.isEmpty
          ? const Center(child: Text('No entries found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _orderDataList.length,
        itemBuilder: (context, index) {
          final order = _orderDataList[index];
          final displayData = Map<String, dynamic>.from(order)
            ..remove('id')
            ..remove('https://idcardprojectapis.logicaldottech.com/externalFiles/userpic.png');
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, spreadRadius: 2),
              ],
            ),
            child: Stack(
              children: [
                // Left Vertical Indicator
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    decoration: BoxDecoration(
                      color: const Color(0XFF7653F6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image/avatar placeholder
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: order['https://idcardprojectapis.logicaldottech.com/externalFiles/userpic.png'] != null
                            ? NetworkImage(order['https://idcardprojectapis.logicaldottech.com/externalFiles/userpic.png'])
                            : null,
                        child: order['https://idcardprojectapis.logicaldottech.com/externalFiles/userpic.png'] == null
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: displayData.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${entry.key}: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: const Color(0XFF555555),
                                      ),
                                    ),
                                    TextSpan(
                                      text: entry.value ?? 'N/A',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Add edit functionality here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF7653F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              _deleteOrder(order['id']);
                            },
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0XFF262626),
                                  fontWeight: FontWeight.bold),
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
        child: BlocConsumer<CreateOrderCubit, CreateOrderState>(
          listener: (context, state) {
            if (state is CreateOrderLoadingState) {
              _showLoadingDialog();
            } else if (state is CreateOrderSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Order Submit Successfully"),
                  duration: Duration(seconds: 3),
                ),

              );
              Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.home);
              _dismissLoadingDialog();
            } else {
              _dismissLoadingDialog();
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () async {
                // Based on orderType, decide which method to call
                if (widget.orderType == 'array') {
                  await _submitForm();
                } else if (widget.orderType == 'excel') {
                  await _submitExcelFile();
                }
                // Refresh orders after submission
             //   await _fetchOrders();
              },
              child: const Text("Place Order", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7653F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}
