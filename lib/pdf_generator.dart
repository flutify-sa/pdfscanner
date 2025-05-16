// ignore_for_file: avoid_print

import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class PdfGenerator {
  static Future<String?> createPdfFromImage({required String imagePath}) async {
    try {
      final pdf = pw.Document();
      final image = File(imagePath);
      final imageBytes = await image.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );

      // Ensure permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        return null;
      }

      // Create a user-visible directory in Downloads
      final downloadsDir = Directory(
        '/storage/emulated/0/Download/FlutifyScan',
      );
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }
}
