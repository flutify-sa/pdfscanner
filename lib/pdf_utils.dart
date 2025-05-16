import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class PdfUtils {
  static void showPdfCreatedSnackbar(BuildContext context, String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('PDF created!'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            OpenFile.open(filePath);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
