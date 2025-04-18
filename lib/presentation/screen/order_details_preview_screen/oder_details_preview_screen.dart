import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled/components/back_button.dart';
import 'package:untitled/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../bloc/order_details_preview_bloc/order_details_preview_cubit.dart';
import '../../bloc/order_details_preview_bloc/order_details_preview_state.dart';

class OrderDetailsPreviewScreen extends StatefulWidget {
  final String orderId;
  final String imageUrl;
  const OrderDetailsPreviewScreen(
      {Key? key, required this.orderId, required this.imageUrl})
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
    context
        .read<OrderDetailsPreviewCubit>()
        .fetchOrderDetails(orderId: widget.orderId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      context
          .read<OrderDetailsPreviewCubit>()
          .fetchOrderDetails(orderId: widget.orderId, isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Order Details Preview",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: const Padding(
              padding: EdgeInsets.only(left: 20), child: SLBackButton()),
        ),
        body: BlocBuilder<OrderDetailsPreviewCubit, OrderDetailsPreviewState>(
          builder: (context, state) {
            final isPortrait =
                context.read<OrderDetailsPreviewCubit>().isPortrait;
            if (state is OrderDetailsPreviewRequestLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderDetailsPreviewSuccessState) {
              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.orderData.length + (state.hasMoreData ? 1 : 0),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
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
                  final controller = PageController(initialPage: 0);

                  return Container(
                    // elevation: 3,
                    // surfaceTintColor: Colors.white,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(26, 119, 119, 119),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: Offset(4, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 2,
                        )),
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: isPortrait ? 200 : double.maxFinite,
                              height: isPortrait ? 330 : 220,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: PageView(
                                      controller: controller,
                                      children: [
                                        WebViewContainer(
                                            url:
                                                "https://api.todaystrends.site/processed_svgs/${order.processedFilesWatermarked}"),
                                        if (order
                                                .processedBackFilesWatermarked !=
                                            null)
                                          WebViewContainer(
                                              url:
                                                  "https://api.todaystrends.site/processed_svgs/${order.processedBackFilesWatermarked}"),
                                      ],
                                    ),
                                  ),
                                  if (order.processedBackFilesWatermarked !=
                                      null)
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: SmoothPageIndicator(
                                              controller:
                                                  controller, // PageController
                                              count: 2,
                                              effect: const ScrollingDotsEffect(
                                                  activeDotColor:
                                                      AppColors.goldenYellow,
                                                  dotHeight: 8,
                                                  dotWidth: 8,
                                                  radius:
                                                      4), // your preferred effect
                                              onDotClicked: (index) {
                                                controller.jumpToPage(index);
                                              }),
                                        ))
                                ],
                              )),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'Student Name: ',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.gray110),
                                ),
                                TextSpan(
                                  text: order.studentName ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.black),
                                ),
                              ],
                            ),
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
          setState(() {});
        },
        onPageFinished: (url) {
          _disableScrolling();
          setState(() {});
        },
        onWebResourceError: (error) {
          setState(() {});
        },
      ))
      ..loadRequest(Uri.parse(widget.url)).catchError((e) {
        print("Load request failed: $e");
        setState(() {});
      });

    _injectViewportMeta();
  }

  void _disableScrolling() {
    _controller.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);

            document.body.style.overflow = 'hidden';
            document.documentElement.style.overflow = 'hidden';
          ''');
  }

  void _injectViewportMeta() {
    _controller.runJavaScript('''
      var meta = document.createElement('meta'); 
      meta.name = 'viewport'; 
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; 
      document.getElementsByTagName('head')[0].appendChild(meta);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
