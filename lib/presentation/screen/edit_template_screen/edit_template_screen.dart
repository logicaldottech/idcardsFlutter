import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled/components/back_button.dart';
import 'package:untitled/domain/models/edit_template_models/edit_template_request.dart';
import 'package:untitled/domain/models/template_models/template_response.dart';
import 'package:untitled/presentation/screen/edit_template_screen/edit_template_dialog.dart';
import 'package:untitled/presentation/screen/edit_template_screen/font_colors.dart';
import 'package:untitled/presentation/screen/edit_template_screen/font_family_dropdown.dart';
import 'package:untitled/presentation/screen/edit_template_screen/font_styles_row.dart';
import 'package:untitled/presentation/screen/student_form/student_form_screen.dart';
import 'package:untitled/theme/app_colors.dart';
import 'package:untitled/utils/loading_animation.dart';
import 'package:untitled/utils/vl_toast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/data_sources/local/preference_utils.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/common_bottom_navigation.dart';
import '../../bloc/update_template_bloc/update_template_cubit.dart';
import '../../bloc/update_template_bloc/update_template_state.dart';

class EditTemplateScreen extends StatefulWidget {
  final Template template;
  const EditTemplateScreen({
    super.key,
    required this.template,
  });

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  late final WebViewController _webViewController;
  late final WebViewController _backWebViewController;
  int _selectedIndex = 0;
  Map<int, String> modifiedTexts = {};
  String schoolId = "";
  bool isLoading = true;
  final pageController = PageController(initialPage: 0);
  WebViewController? webViewController;
  double? fontSize;
  Color? fontColor;
  int? elementId;
  String? elementText;
  String? fontFamily;
  bool? isBold;
  bool? isItalic;
  bool? isUnderline;

  void reset() {
    webViewController = null;
    fontSize = null;
    fontColor = null;
    fontFamily = null;
    isBold = null;
    isItalic = null;
    isUnderline = null;
    elementId = null;
    elementText = null;
    setState(() {});
  }

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
        _handleTextClick(message.message, _webViewController);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          _webViewController.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);

            document.body.style.overflow = 'hidden';
            document.documentElement.style.overflow = 'hidden';
          ''');
          // _injectJavaScript();
          isLoading = false;
          setState(() {});
        },
        onWebResourceError: (error) {
          isLoading = false;
          setState(() {});
          // Optionally log the error; do nothing to prevent error text from showing.
        },
      ))
      ..loadRequest(Uri.parse(widget.template.edittemplateimageUrl ?? ""));

    if (widget.template.edittemplateBackUrl != null) {
      _backWebViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel("FlutterChannel", onMessageReceived: (message) {
          _handleTextClick(message.message, _backWebViewController);
        })
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) {
            _backWebViewController.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);

            document.body.style.overflow = 'hidden';
            document.documentElement.style.overflow = 'hidden';
          ''');
            // _injectJavaScript();
            isLoading = false;
            setState(() {});
          },
          onWebResourceError: (error) {
            isLoading = false;
            setState(() {});
            // Optionally log the error; do nothing to prevent error text from showing.
          },
        ))
        ..loadRequest(Uri.parse(widget.template.edittemplateBackUrl ?? ""));
    }
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

  void _handleTextClick(String message, WebViewController controller) {
    reset();
    final data = jsonDecode(message);
    final RegExp fontSizeRegex = RegExp(r'font-size:\s*(\d+\.?\d*)px');
    final RegExp fontFamilyRegex = RegExp(r'font-family:\s*([^;]+);');
    final RegExp fontColorRegex =
        RegExp(r'color:\s*rgb\((\d+),\s*(\d+),\s*(\d+)\)');
    final RegExp fontWeightRegex = RegExp(r'font-weight:\s*(bold|[5-9]\d{2})');
    final RegExp fontStyleRegex = RegExp(r'font-style:\s*(italic)');
    final RegExp textDecorationRegex =
        RegExp(r'text-decoration:\s*(underline)');

    String? fontFamily;

    if (data['text'].isNotEmpty) {
      final style = data['style'] ?? '';

      final fontSizeMatch = fontSizeRegex.firstMatch(style);
      if (fontSizeMatch != null) {
        fontSize = double.tryParse(fontSizeMatch.group(1)!);
      }

      final fontFamilyMatch = fontFamilyRegex.firstMatch(style);
      if (fontFamilyMatch != null) {
        fontFamily = fontFamilyMatch.group(1)!.trim();
        if ((fontFamily.startsWith('"') && fontFamily.endsWith('"')) ||
            (fontFamily.startsWith("'") && fontFamily.endsWith("'"))) {
          fontFamily = fontFamily.substring(1, fontFamily.length - 1);
        }
      }

      final fontColorMatch = fontColorRegex.firstMatch(style);
      if (fontColorMatch != null) {
        int r = int.parse(fontColorMatch.group(1)!);
        int g = int.parse(fontColorMatch.group(2)!);
        int b = int.parse(fontColorMatch.group(3)!);
        fontColor = Color.fromRGBO(r, g, b, 1.0);
      }

      final fontWeightMatch = fontWeightRegex.firstMatch(style);
      if (fontWeightMatch != null) {
        isBold = fontWeightMatch.group(1) == 'bold' ||
            int.tryParse(fontWeightMatch.group(1)!) != null;
      }

      final fontStyleMatch = fontStyleRegex.firstMatch(style);
      isItalic = fontStyleMatch != null;

      final textDecorationMatch = textDecorationRegex.firstMatch(style);
      isUnderline = textDecorationMatch != null;
      this.fontFamily = fontFamily;
      elementId = data['id'];
      elementText = data['text'];
      final definedFontSize = preRenderedFontSize[elementId!];
      if (fontSize != null && definedFontSize == null) {
        preRenderedFontSize[elementId!] = fontSize!.toInt();
      }
      webViewController = pageController.page == 0
          ? _webViewController
          : _backWebViewController;
      setState(() {});
      // _showEditDialog(
      //     selectedText: data['text'],
      //     selectedElementId: data['id'],
      //     fontSize: fontSize,
      //     fontColor: fontColor,
      //     fontFamily: fontFamily,
      //     isBold: isBold,
      //     isItalic: isItalic,
      //     isUnderline: isUnderline,
      //     webViewController: controller);
    }
  }

  Map<int, int> preRenderedFontSize = {};

  void _showEditDialog(
      {required String selectedText,
      required int selectedElementId,
      double? fontSize,
      Color? fontColor,
      String? fontFamily,
      bool? isBold,
      bool? isItalic,
      bool? isUnderline,
      required WebViewController webViewController}) {
    // write code to genrate list of int according to font sizes if its non null then 10 to 16 if non null then it should have 5 options like 10,11,12,13,14 from the current fontsize 2 incremental and 2 decremental
    int? previousSelectedFontSize = preRenderedFontSize[selectedElementId];

    showDialog(
      context: context,
      builder: (context) {
        return EditTemplateDialog(
            selectedText: selectedText,
            onApply:
                (fs, fontColor, fontFamily, isBold, isItalic, isUnderline) {
              if (fontSize != null &&
                  preRenderedFontSize[selectedElementId] == null) {
                preRenderedFontSize[selectedElementId] = fontSize.toInt();
              }
              _updateTextStyle(
                  selectedText: selectedText,
                  selectedElementId: selectedElementId,
                  fontSize: fs,
                  fontColor: fontColor,
                  fontFamily: fontFamily,
                  webViewController: webViewController,
                  isBold: isBold,
                  isItalic: isItalic,
                  isUnderline: isUnderline);
            },
            fontSize: fontSize,
            fontColor: fontColor,
            fontFamily: fontFamily,
            isBold: isBold,
            isItalic: isItalic,
            isUnderline: isUnderline,
            definedFontSize: previousSelectedFontSize?.toDouble());
      },
    );
  }

  void _updateFontSize({
    required int selectedElementId,
    required double fontSize,
    required WebViewController webViewController,
  }) {
    webViewController.runJavaScript('''
    (function(id, fontSize) {
      let element = document.querySelector(`[data-id='${selectedElementId}']`);
      if (element && fontSize !== null) {
        element.style.fontSize = fontSize + "px";
      }
    })("$selectedElementId", $fontSize);
  ''');
  }

  void _updateFontColor({
    required int selectedElementId,
    required Color fontColor,
    required WebViewController webViewController,
  }) {
    final colorHex = '#${fontColor.value.toRadixString(16).substring(2)}';
    webViewController.runJavaScript('''
    (function(id, colorHex) {
      let element = document.querySelector(`[data-id='${selectedElementId}']`);
      if (element && colorHex !== null) {
        element.style.color = colorHex;
      }
    })("$selectedElementId", "$colorHex");
  ''');
  }

  void _updateFontFamily({
    required int selectedElementId,
    required String fontFamily,
    required WebViewController webViewController,
  }) {
    webViewController.runJavaScript('''
    (function(id, fontFamily) {
      let element = document.querySelector(`[data-id='${selectedElementId}']`);
      if (element && fontFamily !== null) {
        element.style.fontFamily = fontFamily;
      }
    })("$selectedElementId", "$fontFamily");
  ''');
  }

  void _updateFontWeight({
    required int selectedElementId,
    required bool isBold,
    required WebViewController webViewController,
  }) {
    final fontWeight = isBold ? 'bold' : 'normal';
    webViewController.runJavaScript('''
    (function(id, fontWeight) {
      let element = document.querySelector(`[data-id='${selectedElementId}']`);
      if (element) {
        element.style.fontWeight = fontWeight;
      }
    })("$selectedElementId", "$fontWeight");
  ''');
  }

  void _updateFontStyle({
    required int selectedElementId,
    required bool isItalic,
    required WebViewController webViewController,
  }) {
    final fontStyle = isItalic ? 'italic' : 'normal';
    webViewController.runJavaScript('''
    (function(id, fontStyle) {
      let element = document.querySelector(`[data-id='${selectedElementId}']`);
      if (element) {
        element.style.fontStyle = fontStyle;
      }
    })("$selectedElementId", "$fontStyle");
  ''');
  }

  void _updateTextDecoration({
    required int selectedElementId,
    required bool isUnderline,
    required WebViewController webViewController,
  }) {
    final textDecoration = isUnderline ? 'underline' : 'none';
    webViewController.runJavaScript('''
    (function(id, textDecoration) {
      let element = document.querySelector(`[data-id='${selectedElementId}']`);
      if (element) {
        element.style.textDecoration = textDecoration;
      }
    })("$selectedElementId", "$textDecoration");
  ''');
  }

  void _updateTextStyle(
      {required String selectedText,
      required int selectedElementId,
      double? fontSize,
      Color? fontColor,
      String? fontFamily,
      bool? isBold,
      bool? isItalic,
      bool? isUnderline,
      required WebViewController webViewController}) {
    try {
      String? colorHex = fontColor != null
          ? '#${fontColor.value.toRadixString(16).substring(2)}'
          : null;
      String updatedText = selectedText;

      webViewController.runJavaScript('''
    (function(id, newText, fontSize, colorHex, fontFamily, isBold, isItalic, isUnderline) {
        let element = document.querySelector(`[data-id='${selectedElementId}']`);
        if (element) {
            element.innerText = newText;
            if (fontSize !== null) element.style.fontSize = fontSize + "px";
            if (fontFamily !== null) element.style.fontFamily = fontFamily;
            if (colorHex !== null) element.style.color = colorHex;
            
            // Apply font styles only if they are not null
            if (isBold !== null) element.style.fontWeight = isBold ? 'bold' : 'normal';
            if (isItalic !== null) element.style.fontStyle = isItalic ? 'italic' : 'normal';
            if (isUnderline !== null) element.style.textDecoration = isUnderline ? 'underline' : 'none';
        }
    })("$selectedElementId", "$updatedText", ${fontSize ?? 'null'}, "${colorHex ?? 'null'}", "${fontFamily ?? 'null'}", ${isBold == null ? 'null' : isBold.toString()}, ${isItalic == null ? 'null' : isItalic.toString()}, ${isUnderline == null ? 'null' : isUnderline.toString()});
  ''');
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _generateAndSendHtml() async {
    final script = """
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
    """;
    try {
      String? modifiedHtml = await _webViewController
          .runJavaScriptReturningResult(script) as String?;

      if (modifiedHtml == null || modifiedHtml.isEmpty) {
        throw Exception("JavaScript execution returned null or empty string.");
      }

// Step 1. Unescape the Unicode escape sequences.
      // Replace \u003C with <, \u003E with >, and unescape any escaped quotes.
      String frontCardHtml = modifiedHtml
          .replaceAll(r'\u003C', '<')
          .replaceAll(r'\u003E', '>')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\"', '"');

      // Remove the surrounding quotes if present.
      if (frontCardHtml.startsWith('"') && frontCardHtml.endsWith('"')) {
        frontCardHtml = frontCardHtml.substring(1, frontCardHtml.length - 1);
      }

      String? backHtml;

      if (widget.template.edittemplateBackUrl != null) {
        String? htmlString = await _backWebViewController
            .runJavaScriptReturningResult(script) as String?;

        if (htmlString == null || htmlString.isEmpty) {
          throw Exception(
              "JavaScript execution returned null or empty string.");
        }

// Step 1. Unescape the Unicode escape sequences.
        // Replace \u003C with <, \u003E with >, and unescape any escaped quotes.
        backHtml = htmlString
            .replaceAll(r'\u003C', '<')
            .replaceAll(r'\u003E', '>')
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\"', '"');

        // Remove the surrounding quotes if present.
        if (backHtml.startsWith('"') && backHtml.endsWith('"')) {
          backHtml = backHtml.substring(1, backHtml.length - 1);
        }
      }

      Navigator.of(context).pushNamed(PageRoutes.studentFormDetails,
          arguments: StudentFormArguments(
              id: widget.template.id!,
              frontHtml: frontCardHtml,
              backHtml: backHtml));

      // Step 2. Parse the HTML string into a DOM document.
      // Document document = htmlParser.parse(unescapedHtml);
      // Additional cleanup in Dart to ensure any remaining text="..." attributes are removed
      // modifiedHtml = modifiedHtml.replaceAll(RegExp(r'text="[^"]*"'), '');

      // // Remove any extra quotation marks at the start and end of the string
      // modifiedHtml = modifiedHtml.trim();
      // if (modifiedHtml.startsWith('""')) {
      //   modifiedHtml = modifiedHtml.substring(2); // Remove the leading ""
      // }
      // if (modifiedHtml.endsWith('""')) {
      //   modifiedHtml = modifiedHtml.substring(
      //       0, modifiedHtml.length - 2); // Remove the trailing ""
      // }

//TODO: send html to backend is nnow changed it will be sent to orderDetailPage
    } catch (e) {
      print("❌ Error while generating HTML: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Editor",
            style: GoogleFonts.instrumentSans(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: SLBackButton(),
          ),
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? const LoadingAnimation()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: widget.template.isPortait == true ? 330 : 220,
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (value) {
                          reset();
                        },
                        children: [
                          KeepAliveWebView(
                            controller: _webViewController,
                            isPortait: widget.template.isPortait,
                          ),
                          if (widget.template.edittemplateBackUrl != null)
                            KeepAliveWebView(
                              controller: _backWebViewController,
                              isPortait: widget.template.isPortait,
                            ),
                        ],
                      ),
                    ),
                    if (widget.template.edittemplateBackUrl != null)
                      Align(
                          alignment: Alignment.centerRight,
                          child: StatefulBuilder(builder: (context, setState) {
                            return GestureDetector(
                              onTap: () {
                                final currentPage =
                                    pageController.page?.toInt() ?? 0;
                                pageController
                                    .jumpToPage(currentPage == 0 ? 1 : 0);
                                setState(() {});
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
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
                          })),
                    // Center(
                    //   child: SmoothPageIndicator(
                    //       controller: pageController, // PageController
                    //       count: 2,
                    //       effect: const ExpandingDotsEffect(
                    //           dotHeight: 10,
                    //           dotWidth: 10,
                    //           radius: 5), // your preferred effect
                    //       onDotClicked: (index) {
                    //         pageController.jumpToPage(index);
                    //         reset();
                    //       }),
                    // ),

                    if (elementId != null)
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 16,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                elementText ?? '',
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.charcoalGray),
                              ),
                            ),
                            FontFamilyDropDown(
                                selectedFontFamily: fontFamily,
                                onFontFamilyChanged: (fontFamily) {
                                  _updateFontFamily(
                                      selectedElementId: elementId!,
                                      fontFamily: fontFamily,
                                      webViewController: webViewController!);
                                  setState(() {
                                    this.fontFamily = fontFamily;
                                  });
                                }),
                            FontStylesRow(
                                isBold: isBold ?? false,
                                isItalic: isItalic ?? false,
                                isUnderline: isUnderline ?? false,
                                fontSize: fontSize,
                                definedFontSize:
                                    preRenderedFontSize[elementId]?.toDouble(),
                                onFontSizeChange: (fontSize) {
                                  _updateFontSize(
                                      selectedElementId: elementId!,
                                      fontSize: fontSize,
                                      webViewController: webViewController!);
                                  setState(() {
                                    this.fontSize = fontSize;
                                  });
                                },
                                onBoldChange: (isBold) {
                                  _updateFontWeight(
                                      selectedElementId: elementId!,
                                      isBold: isBold,
                                      webViewController: webViewController!);
                                  setState(() {
                                    this.isBold = isBold;
                                  });
                                },
                                onItalicChange: (isItalic) {
                                  _updateFontStyle(
                                      selectedElementId: elementId!,
                                      isItalic: isItalic,
                                      webViewController: webViewController!);
                                  setState(() {
                                    this.isItalic = isItalic;
                                  });
                                },
                                onUnderlineChange: (isUnderlined) {
                                  _updateTextDecoration(
                                      selectedElementId: elementId!,
                                      isUnderline: isUnderlined,
                                      webViewController: webViewController!);
                                  setState(() {
                                    isUnderline = isUnderlined;
                                  });
                                }),
                            FontColors(
                                fontColor: fontColor,
                                onFontColorChanged: (fontColor) {
                                  _updateFontColor(
                                      selectedElementId: elementId!,
                                      fontColor: fontColor,
                                      webViewController: webViewController!);
                                  setState(() {
                                    this.fontColor = fontColor;
                                  });
                                })
                          ],
                        )),
                      ))
                    else
                      const Spacer(),

                    /// Order Now Button Above Bottom Navigation Bar with BlocConsumer
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton.icon(
                          onPressed: _generateAndSendHtml,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF7653F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: const Text(
                            'Enter Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class KeepAliveWebView extends StatefulWidget {
  final WebViewController controller;
  final bool isPortait;

  const KeepAliveWebView(
      {super.key, required this.controller, required this.isPortait});

  @override
  State<KeepAliveWebView> createState() => _KeepAliveWebViewState();
}

class _KeepAliveWebViewState extends State<KeepAliveWebView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: widget.isPortait ? 200 : double.maxFinite,
        height: widget.isPortait ? 330 : 220,
        child: WebViewWidget(controller: widget.controller),
      ),
    );
  }
}
