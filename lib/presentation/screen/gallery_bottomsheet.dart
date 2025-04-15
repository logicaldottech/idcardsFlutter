import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomBottomSheet(
  BuildContext context, {
  VoidCallback? onRecentPictures,
  VoidCallback? onSelectFromGallery,
  VoidCallback? onSelectFromLocalFiles,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Color(0xFFFAFAFA),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildOption(
                  context,
                  Icons.access_time,
                  "Recent\nPictures",
                  onRecentPictures,
                ),
                buildOption(
                  context,
                  Icons.photo,
                  "Select from\nGallery",
                  onSelectFromGallery,
                ),
                buildOption(
                  context,
                  Icons.folder,
                  "Select from\nLocal Files",
                  onSelectFromLocalFiles,
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Widget buildOption(
  BuildContext context,
  IconData icon,
  String text,
  VoidCallback? onTap,
) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
      if (onTap != null) onTap();
    },
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: Colors.black54),
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.black54),
          softWrap: true,
          maxLines: 2,
        ),
      ],
    ),
  );
}
