// ignore_for_file: avoid_print
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

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

      // Request storage permission (you already do this)

      // Get external storage directory
      final extDir = await getExternalStorageDirectory();

      // Construct path for Downloads/FlutifyScan inside your app's external directory
      final downloadsDir = Directory('${extDir!.path}/FlutifyScan');
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
