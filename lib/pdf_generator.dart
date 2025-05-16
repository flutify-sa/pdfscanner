import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  /// Converts a single image file at [imagePath] into a PDF,
  /// saves it in app documents directory with the given [fileName],
  /// and returns the saved PDF file path.
  static Future<String> createPdfFromImage({
    required String imagePath,
    String? fileName,
  }) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(File(imagePath).readAsBytesSync());

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final pdfFileName =
        fileName ?? 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final pdfPath = '${dir.path}/$pdfFileName';

    final file = File(pdfPath);
    await file.writeAsBytes(await pdf.save());

    return pdfPath;
  }
}
