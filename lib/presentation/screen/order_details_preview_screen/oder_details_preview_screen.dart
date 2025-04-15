import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../bloc/order_details_preview_bloc/order_details_preview_cubit.dart';
import '../../bloc/order_details_preview_bloc/order_details_preview_state.dart';

class OrderDetailsPreviewScreen extends StatefulWidget {
  final String orderId;
  final String imageUrl;
  const OrderDetailsPreviewScreen({Key? key, required this.orderId, required this.imageUrl})
      : super(key: key);

  @override
  State<OrderDetailsPreviewScreen> createState() =>
      _OrderDetailsPreviewScreenState();
}

class _OrderDetailsPreviewScreenState extends State<OrderDetailsPreviewScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchInitialData();
  }

  void _fetchInitialData() {
    context.read<OrderDetailsPreviewCubit>().fetchOrderDetails(orderId: widget.orderId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      context.read<OrderDetailsPreviewCubit>().fetchOrderDetails(orderId: widget.orderId, isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Order Details Preview", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:BlocBuilder<OrderDetailsPreviewCubit, OrderDetailsPreviewState>(
        builder: (context, state) {
          if (state is OrderDetailsPreviewRequestLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderDetailsPreviewSuccessState) {
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.orderData.length + (state.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when fetching more data
                if (index == state.orderData.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final order = state.orderData[index];


                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 350,
                          child: WebViewContainer(url: "https://idcardprojectapis.logicaldottech.com/processed_svgs/${order.processedFilesWatermarked}"),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Student Name: ${order.studentName ?? 'N/A'}", // Handle null names safely
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is OrderDetailsPreviewErrorState) {
            return Center(
              child: Text(
                state.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: Text("No data available."));
        },
      ),
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
          setState(() {

          });
        },
        onPageFinished: (url) {
          setState(() {

          });

        },
        onWebResourceError: (error) {
          setState(() {

          });

        },
      ))
      ..loadRequest(Uri.parse(widget.url)).catchError((e) {
        print("Load request failed: $e");
        setState(() {

        });



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
