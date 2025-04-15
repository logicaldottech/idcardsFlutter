import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/data_sources/local/preference_utils.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/common_bottom_navigation.dart';
import '../../bloc/order_history_bloc/order_history_cubit.dart';
import '../../bloc/order_history_bloc/order_history_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedIndex = 2;
  String? studentId;

  @override
  void initState() {
    super.initState();
    _getStudentId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Order History",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Handle back navigation
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        builder: (context, state) {
          if (state is OrderHistoryLoadingState || state is OrderHistoryRequestLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderHistorySuccessState) {
            final orders = state.response.data.orders;
            print("orderDataResponse ${orders}");

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders?.length,
              itemBuilder: (context, index) {
                final order = orders?[index];
                return _buildOrderCard(order);
              },
            );
          } else if (state is OrderHistoryErrorState) {
            return Center(child: Text(state.error.toString()));
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildOrderCard(order) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed(
          PageRoutes.orderDetailsPreviewScreen,
          arguments: {
            'imageUrl': 'https://idcardprojectapis.logicaldottech.com/thumbnails/${order?.thumbnailfileNameFront}',
            'id': order.id.toString(),
          },
        );
      },
      child: Container(
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
                  color: Color(0XFF7653F6), // Different color for each status
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Profile picture
            // Order Image (Left Side)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        _formatDate(order?.createdAt),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildOrderImage(order?.thumbnailfileNameFront),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date at Top Right

                            const SizedBox(height: 4),
                            _buildText("Order ID", order?.id, color : Color(0XFF7653F6)),
                            _buildText("Order Status", order?.status, color: Color(0XFF7653F6)),
                            _buildText("Order Type", order?.orderType, color: Color(0XFF7653F6)),
                            _buildText("Qty", "${order?.totalItems} pcs.", color: Color(0XFF7653F6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }


  // Helper function to handle image display
  // Helper function to handle image display
  Widget _buildOrderImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder();
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8), // Keep rounded corners
        child: Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300], // Background in case of delay
          ),
          child: Image.network(
            'https://idcardprojectapis.logicaldottech.com/thumbnails/$imageUrl',
            width: 80,
            height: 100,
            fit: BoxFit.fill, // Crops and fills container properly
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        ),
      );
    }
  }

// Placeholder function for error/no image
  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _fetchOrderHistory() {
    if (studentId != null) {
      context.read<OrderHistoryCubit>().fetchOrderHistory(studentId!);
    }
  }

  void _getStudentId() async {
    studentId = await PreferencesUtil.getString(AppConstants.schoolId);
    setState(() {
      _fetchOrderHistory();
    });
  }

  Widget _buildText(String label, String? value, {Color? color, bool isLink = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: value.length > 18? '${value.substring(0, 18)}...' : value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
                color: color ?? Colors.black,
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "--/--/--";
    return DateFormat("dd/MM/yy").format(date);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "completed":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
