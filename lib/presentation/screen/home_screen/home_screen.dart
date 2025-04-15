import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/common_bottom_navigation.dart';
import '../../bloc/template_bloc/template_cubit.dart';
import '../../bloc/template_bloc/template_state.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation/page_routes.dart';
import '../../bloc/template_bloc/template_cubit.dart';
import '../../bloc/template_bloc/template_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isPortrait = true;

  @override
  void initState() {
    super.initState();
    context.read<TemplateCubit>().fetchTemplates();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }
  void showActionRequiredDialog(BuildContext context,  String? templateId, String imageUrl, String? backFileName, String? backFile, bool
  isPortait) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF7653F6),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Action Required',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Do you want to edit the card or want to add details?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed(
                              PageRoutes.editTemplateScreen,
                              arguments: {
                                'imageUrl': imageUrl,
                                'id': templateId,
                                'backImageUrl': backFileName,
                                'backFile' : backFile,
                                'portait' : isPortait
                              },
                            );
                            // Add edit action here
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text('Edit Now', style: GoogleFonts.poppins()),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF7653F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed(
                              PageRoutes.studentFormDetails,
                              arguments: {
                                'imageUrl': imageUrl,
                                'id': templateId,
                                'backImageUrl': backFileName != null
                                    ? backFileName
                                    : null,
                                'portait' : isPortait

                              },
                            );
                            // Add order action here
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: Colors.black87,
                            size: 18,
                          ),
                          label: Text(
                            'Order Now',
                            style: GoogleFonts.poppins(color: Colors.black87),
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
    );
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              "LOGO",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0XFF7653F6),
              ),
            ),
            Row(
              children: [
                Icon(Icons.search, color: Colors.black, size: 24,),

                SizedBox(width: 12),
                Icon(Icons.notifications_none, color: Colors.black, size: 24,),

              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isPortrait) {
                          setState(() => isPortrait = false);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isPortrait ? Colors.white : Color(0XFF7653F6),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Landscape",
                          style: TextStyle(
                            color: isPortrait ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isPortrait) {
                          setState(() => isPortrait = true);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isPortrait ? Color(0XFF7653F6) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Portrait",
                          style: TextStyle(
                            color: isPortrait ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TemplateCubit, TemplateState>(
              builder: (context, state) {
                if (state is TemplateLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TemplateSuccessState) {
                  // Filtering templates based on orientation
                  var filteredTemplates = state.response.data?.templates
                      ?.where((template) =>
                  (isPortrait && template.orientation == "vertical") ||
                      (!isPortrait && template.orientation == "horizontal"))
                      .toList() ??
                      [];

                  if (filteredTemplates.isEmpty) {
                    return const Center(
                        child: Text("No templates available for this orientation"));
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.8, // Limit height for ListView
                    child: ListView.builder(
                      key: ValueKey(isPortrait), // Forces refresh on orientation change
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredTemplates.length,
                      itemBuilder: (context, index) {
                        String? fileName = filteredTemplates[index].fileName;
                        String? backFileName = filteredTemplates[index].backFileName;
                        String? thumbnailfileName =
                            filteredTemplates[index].thumbnailfileNameFront;
                        String? thumbnailbackfileName =
                            filteredTemplates[index].thumbnailfileNameBack;

                        String imageUrl =
                            "https://idcardprojectapis.logicaldottech.com/thumbnails/$thumbnailfileName";
                        String backImageUrl =
                            "https://idcardprojectapis.logicaldottech.com/thumbnails/$thumbnailbackfileName";
                        String? edittemplateimageUrl =
                            "https://idcardprojectapis.logicaldottech.com/templates/$fileName";
                        String? edittemplateBackUrl =
                            "https://idcardprojectapis.logicaldottech.com/templates/$backFileName";

                        return GestureDetector(
                          onTap: () {
                            showActionRequiredDialog(
                              context,
                              filteredTemplates[index].id,
                              edittemplateimageUrl,
                              edittemplateBackUrl,
                              backFileName,
                              isPortrait,
                            );
                          },
                          child: Card(
                            color: isPortrait
                                ? const Color(0XFFDDD3FF)
                                : Colors.white,
                            surfaceTintColor: isPortrait
                                ? const Color(0XFFDDD3FF)
                                : Colors.white,
                            elevation: 4, // Optional: Adds shadow
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width, // Full card width
                              height: isPortrait
                                  ? null
                                  : 250, // Height 250 for landscape, null for portrait
                              child: isPortrait
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 300,
                                    child: Image.network(
                                      imageUrl, // Replace with actual image URL
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                            child:
                                            CircularProgressIndicator());
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error);
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (backFileName != null) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 200,
                                      height: 310,
                                      child: Image.network(
                                        backImageUrl,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                              child:
                                              CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.error);
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                                  : Stack(
                                alignment: Alignment.center,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          height: 300,
                                          child: Image.network(
                                            imageUrl,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                  child:
                                                  CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, error,
                                                stackTrace) {
                                              return Icon(Icons.error);
                                            },
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (backFileName != null) ...[
                                          SizedBox(
                                            width: 370,
                                            height: 200,
                                            child: Image.network(
                                              backImageUrl,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                    child:
                                                    CircularProgressIndicator());
                                              },
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return Icon(Icons.error);
                                              },
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (backFileName != null)
                                    const Positioned(
                                      bottom: 8.0,
                                      child: Text(
                                        "..",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is TemplateErrorState) {
                  return Center(child: Text("Error: ${state.error}"));
                }
                return const Center(child: Text("No Data Available"));
              },
            ),
          ),

        ],

      ),
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
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




