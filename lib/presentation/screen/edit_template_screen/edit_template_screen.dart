import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/models/edit_template_models/edit_template_request.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/data_sources/local/preference_utils.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/common_bottom_navigation.dart';
import '../../bloc/update_template_bloc/update_template_cubit.dart';
import '../../bloc/update_template_bloc/update_template_state.dart';

class EditTemplateScreen extends StatefulWidget {
  final String? imageUrl;
  final String? id;
  final String? backImageUrl;
  final bool? isPortait;
  final String? backFile;




  const EditTemplateScreen({Key? key, required this.imageUrl, required this.id, required this.backImageUrl, bool? this.isPortait, this.backFile,}) : super(key: key);

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  late final WebViewController _webViewController;
  late final WebViewController _backWebViewController;
  int _selectedIndex = 0;
  String selectedText = '';
  int selectedElementId = -1;
  double fontSize = 16;
  Color fontColor = Colors.black;
  Map<int, String> modifiedTexts = {};
  String schoolId = "";
 @override
  void initState() {

    super.initState();
    _initializeWebView();
    _getSchoolId();
  }
  void _getSchoolId() async {
    schoolId = (await PreferencesUtil.getString(AppConstants.schoolId)) ?? "";
    setState(() {});
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }


  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("FlutterChannel", onMessageReceived: (message) {
        _handleTextClick(message.message);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          _injectJavaScript();
        },
        onWebResourceError: (error) {
          // Optionally log the error; do nothing to prevent error text from showing.
        },
      ))
      ..loadRequest(Uri.parse(widget.imageUrl ?? ""));

      _backWebViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("FlutterChannel", onMessageReceived: (message) {
        _handleTextClick(message.message);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          _backInjectJavaScript();
        },
        onWebResourceError: (error) {
          // Silently ignore errors
        },
      ));


  }



  void _injectJavaScript() {
    _webViewController.runJavaScript("""
      setTimeout(() => {
        document.querySelectorAll("span, p, h1, h2, h3, h4, h5, h6, label, strong").forEach((el, index) => {
          if (!el.hasAttribute("data-id")) {
            el.setAttribute("data-id", index);
          }
          el.style.cursor = "pointer";
          el.onclick = function(event) {
            event.stopPropagation();
            if (window.FlutterChannel) {
              window.FlutterChannel.postMessage(JSON.stringify({ id: index, text: el.innerText }));
            }
          };
        });
      }, 1500);
    """);
  }
 void _backInjectJavaScript() {
    _backWebViewController.runJavaScript("""
      setTimeout(() => {
        document.querySelectorAll("span, p, h1, h2, h3, h4, h5, h6, label, strong").forEach((el, index) => {
          if (!el.hasAttribute("data-id")) {
            el.setAttribute("data-id", index);
          }
          el.style.cursor = "pointer";
          el.onclick = function(event) {
            event.stopPropagation();
            if (window.FlutterChannel) {
              window.FlutterChannel.postMessage(JSON.stringify({ id: index, text: el.innerText }));
            }
          };
        });
      }, 1500);
    """);
  }

  void _handleTextClick(String message) {
    final data = jsonDecode(message);
    if (data['text'].isNotEmpty) {
      setState(() {
        selectedText = data['text'];
        selectedElementId = data['id'];
      });
      _showEditDialog();
    }
  }

  void _showEditDialog() {
    double tempFontSize = fontSize;
    Color tempFontColor = fontColor;
    TextEditingController textController = TextEditingController(text: selectedText);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Text"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: textController),
                    SizedBox(height: 10),
                    Text("Font Size"),
                    Wrap(
                      spacing: 8,
                      children: List.generate(11, (index) {
                        int size = 10 + index;
                        return ChoiceChip(
                          label: Text("$size"),
                          selected: tempFontSize == size.toDouble(),
                          onSelected: (_) {
                            setState(() => tempFontSize = size.toDouble());
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 10),
                    Text("Font Color"),
                    Wrap(
                      spacing: 8,
                      children: [
                        Colors.black, Colors.red, Colors.blue, Colors.green,
                        Colors.orange, Colors.purple, Colors.teal, Colors.brown
                      ].map((color) {
                        return _colorBox(color, setState, tempFontColor, (selectedColor) {
                          tempFontColor = selectedColor;
                        });
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      fontSize = tempFontSize;
                      fontColor = tempFontColor;
                      modifiedTexts[selectedElementId] = textController.text;
                    });
                    _updateTextStyle();
                    Navigator.pop(context);
                  },
                  child: Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _colorBox(Color color, StateSetter setState, Color tempColor, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () {
        setState(() => onSelect(color));
      },
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: tempColor == color ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }

  void _updateTextStyle() {
    String colorHex = '#${fontColor.value.toRadixString(16).substring(2)}';
    String updatedText = modifiedTexts[selectedElementId] ?? selectedText;

    _webViewController.runJavaScript('''
      (function(id, newText, fontSize, colorHex) {
          let element = document.querySelector(`[data-id='${selectedElementId}']`);
          if (element) {
              element.innerText = newText;
              element.style.fontSize = fontSize + "px";
              element.style.color = colorHex;
          }
      })("$selectedElementId", "$updatedText", ${fontSize}, "$colorHex");
    ''');
  }

  Future<void> _generateAndSendHtml() async {
    try {
      String? modifiedHtml = await _webViewController.runJavaScriptReturningResult("""
      (function() {
          let allElements = document.querySelectorAll("[data-id]");
          allElements.forEach(el => {
              // Add the intended attributes
              el.setAttribute("text", el.innerText);
              el.setAttribute("font-size", window.getComputedStyle(el).fontSize);
              el.setAttribute("color", window.getComputedStyle(el).color);
          });
          let htmlString = document.documentElement.outerHTML;
         
          htmlString = htmlString.replace(/text="[^"]*"/g, '');
          // Clean up newlines and backslashes
        // htmlString = htmlString.replace(/\\n/g, '').replace(/\\\\/g, '');
          return htmlString; // Return the HTML string directly without JSON.stringify
      })();
    """) as String?;

      if (modifiedHtml == null || modifiedHtml.isEmpty) {
        throw Exception("JavaScript execution returned null or empty string.");
      }

      // Additional cleanup in Dart to ensure any remaining text="..." attributes are removed
      modifiedHtml = modifiedHtml.replaceAll(RegExp(r'text="[^"]*"'), '');

      // Remove any extra quotation marks at the start and end of the string
      modifiedHtml = modifiedHtml.trim();
      if (modifiedHtml.startsWith('""')) {
        modifiedHtml = modifiedHtml.substring(2); // Remove the leading ""
      }
      if (modifiedHtml.endsWith('""')) {
        modifiedHtml = modifiedHtml.substring(0, modifiedHtml.length - 2); // Remove the trailing ""
      }

      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/modified_template.html');

      await file.writeAsString(modifiedHtml);
      if (await file.exists()) {
        context.read<UpdateTemplateCubit>().fetchUpdatedTemplates(
          request: EditTemplateRequest(template: file),
          schoolId: schoolId,
        );
      }
    } catch (e) {
      print("❌ Error while generating HTML: $e");
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Editor",
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
            Navigator.pop(context);
            // Handle back navigation
          },
        ),
        backgroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                SizedBox(
                  width: widget.isPortait == true ? 200 : 330,
                  height: widget.isPortait == true? 300 : 220,
                  child: WebViewWidget(controller: _webViewController),
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: widget.isPortait == true? 200 : 330,
                  height: widget.isPortait == true ? 300 : 220,
                  child: WebViewWidget(controller: _backWebViewController),
                ),
              ],
            ),
          ),

          /// Order Now Button Above Bottom Navigation Bar with BlocConsumer
          Positioned(
            bottom: 40, // Adjust based on BottomNavigationBar height
            left: 20,
            right: 20,
            child: BlocConsumer<UpdateTemplateCubit, UpdateTemplateState>(
              listener: (context, state) {
                if (state is UpdateTemplateSuccessState) {
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    PageRoutes.studentFormDetails,
                    arguments: {
                      'imageUrl': widget.imageUrl,
                      'id': widget.id,
                      'backImageUrl': widget.backImageUrl != null
                          ? widget.backImageUrl
                          : null,
                      'portait' : false

                    },
                  );
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _generateAndSendHtml,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF7653F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    label: Text(
                      'Order Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      /// Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }




}
