import 'package:flutter/material.dart';
import 'package:untitled/navigation/page_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final String? imageUrl;
  final String? id;
  final String? backImageUrl; // Make backImageUrl optional

  const TemplatePreviewScreen({
    Key? key,
    required this.imageUrl,
    required this.id,
    this.backImageUrl, // Optional field
  }) : super(key: key);

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  late WebViewController _frontController;
  WebViewController? _backController; // Nullable for back image

  bool _isFrontLoaded = false;
  bool _isBackLoaded = false;

  @override
  void initState() {
    super.initState();
    _frontController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _isFrontLoaded = true);
        },
        onWebResourceError: (_) {
          setState(() => _isFrontLoaded = false);
        },
      ))
      ..loadRequest(Uri.parse(widget!.imageUrl ?? ""));

    // Initialize WebView for Back Image (only if it's provided)
    if (widget.backImageUrl != null && widget.backImageUrl!.isNotEmpty) {
      _backController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isBackLoaded = true);
          },
          onWebResourceError: (_) {
            setState(() => _isBackLoaded = false);
          },
        ))
        ..loadRequest(Uri.parse(widget.backImageUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview Template")),
      body: Center(
        child: Column(  // Use Row to display front and back side by side, change to Column if needed
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(


              height: 250,
              child: WebViewWidget(controller: _frontController),
            ),
            SizedBox(width: 20), // Spacing between images
            SizedBox(

              height: 250,

              child: WebViewWidget(controller: _backController!),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(PageRoutes.studentFormDetails, arguments: widget.id);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Apply'),
        ),
      ),
    );
  }



}
