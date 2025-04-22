import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pride/presentation/bloc/template_bloc/template_cubit.dart';
import 'package:pride/presentation/bloc/template_bloc/template_state.dart';
import 'package:pride/presentation/screen/home_screen/landscape_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPortrait = true;
  @override
  void initState() {
    super.initState();
    context.read<TemplateCubit>().fetchTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "UK PRIDE",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0XFF7653F6),
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 24,
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.notifications_none,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: isPortrait
                          ? const BoxDecoration(color: Colors.white)
                          : ShapeDecoration(
                              color: const Color(0xFF7653F6),
                              shape: RoundedRectangleBorder(
                                // side: const BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                      alignment: Alignment.center,
                      child: Text(
                        "Landscape",
                        style: GoogleFonts.instrumentSans(
                          color: isPortrait ? Colors.black : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: !isPortrait
                          ? const BoxDecoration(color: Colors.white)
                          : ShapeDecoration(
                              color: const Color(0xFF7653F6),
                              shape: RoundedRectangleBorder(
                                // side: const BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                      alignment: Alignment.center,
                      child: Text(
                        "Portrait",
                        style: TextStyle(
                          color: isPortrait ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
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
                              (isPortrait &&
                                  template.orientation == "vertical") ||
                              (!isPortrait &&
                                  template.orientation == "horizontal"))
                          .toList() ??
                      [];

                  if (filteredTemplates.isEmpty) {
                    return const Center(
                        child: Text(
                            "No templates available for this orientation"));
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.8, // Limit height for ListView
                    child: ListView.separated(
                      key: ValueKey(isPortrait),
                      // Forces refresh on orientation change
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filteredTemplates.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 22,
                      ),
                      itemBuilder: (context, index) {
                        final template = filteredTemplates[index];

                        return TemplateCardView(template: template);
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
    );
  }
}
