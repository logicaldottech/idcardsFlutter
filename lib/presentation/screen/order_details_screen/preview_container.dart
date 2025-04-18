import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PreviewWebViewContainer extends StatefulWidget {
  final String url;
  final String? html;
  final Map<String, dynamic>? data;

  const PreviewWebViewContainer(
      {super.key, required this.url, this.html, this.data});

  @override
  _PreviewWebViewContainerState createState() =>
      _PreviewWebViewContainerState();
}

class _PreviewWebViewContainerState extends State<PreviewWebViewContainer> {
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
          _controller.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);

            document.body.style.overflow = 'hidden';
            document.documentElement.style.overflow = 'hidden';
          ''');
          _addWatermark();
          if (widget.data != null) {
            widget.data!.forEach((key, value) {
              if (key.startsWith('http')) {
                _updateImage(key, value);
              } else {
                _updateWebViewTextByClassNAme(key, value);
              }
            });
          }
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
  }

  void _addWatermark() async {
    const String jsCode = '''
  var container = document.querySelector('.canvas-container');
  if (container) {
    var style = document.createElement('style');
    style.textContent = ".canvas-container::after { content: 'UK Pride'; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%) rotate(-30deg); font-size: 28px; color: rgba(0, 0, 0, 0.3); font-weight: 900; white-space: nowrap; pointer-events: none; letter-spacing: 2px; }";
    container.appendChild(style);
  }
''';

// Run the JavaScript code using your WebView controller.
    await _controller.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
    ;
  }

  void _updateWebViewTextByClassNAme(String className, String text) async {
    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="$className"]');
        if (element) {
          element.innerText = "$text";
        }
      })();
    """;

    await _controller.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
  }

  void _updateImage(String key, String newUrl) {
    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="$key"]');
        if (element) {
          element.src = "$newUrl";
        }
      })();
    """;

    _controller.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
  }

  void _updateLogoImage(String newUrl) {
    // JavaScript to update the text of the element with the matching data-id
    String jsCode = """
      (function() {
        let element = document.querySelector('[id="https://api.todaystrends.site/externalFiles/logo.png"]');
        if (element) {
          element.src = "$newUrl";
        }
      })();
    """;

    _controller.runJavaScript(jsCode).catchError((e) {
      print("Error updating WebView text: $e");
    });
    // if (_backWebViewController != null) {

    // }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
