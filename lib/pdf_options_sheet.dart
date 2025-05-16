// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart'; // Correct import
//import 'package:image_picker/image_picker.dart'; // For XFile

class PdfOptionsSheet {
  static void show(BuildContext context, String pdfPath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100), // replaced withAlpha
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'PDF Saved',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withAlpha(230), // replaced withAlpha
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to do with your PDF?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(190), // replaced withAlpha
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _optionButton(
                context,
                icon: Icons.open_in_new,
                label: 'Open PDF',
                onTap: () {
                  OpenFile.open(pdfPath);
                  Navigator.pop(context);
                },
              ),
              _optionButton(
                context,
                icon: Icons.share,
                label: 'Share PDF',
                onTap: () async {
                  await Share.shareXFiles([
                    XFile(pdfPath),
                  ], text: 'Check out this PDF!');
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),

              _optionButton(
                context,
                icon: Icons.close,
                label: 'Cancel',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _optionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withAlpha(38), // replaced withAlpha
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onTap,
      ),
    );
  }
}
