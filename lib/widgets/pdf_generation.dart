import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class PdfService {
  /// Capture a widget and generate a PDF with preview/share/download
  static Future<void> createAndPreviewPdf(
    GlobalKey widgetKey,
    BuildContext context, {
    String title = 'ResQ Identity Card',
  }) async {
    try {
      // Show loading message
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      // Capture the widget as image
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception("Failed to capture widget image.");

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Styled title
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 28, // Increased font size
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue, // Added color
                    decoration: pw.TextDecoration.underline, // Added decoration
                  ),
                ),
                pw.SizedBox(height: 30), // Increased spacing

                // Styled image
                pw.Center( // Center the image
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0), // Border needed for rounded corners
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)), // Rounded corners
                      boxShadow: [ // Added shadow for depth
                        pw.BoxShadow(
                          color: PdfColors.grey,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: pw.ClipRRect(  // Clip the image to the rounded corners
                      horizontalRadius: 10,
                      verticalRadius: 10,
                      child: pw.Image(pw.MemoryImage(imageBytes)),
                    ),
                  ),
                ),

                pw.SizedBox(height: 30), // Increased spacing

                // Styled generated on text
                pw.Text(
                  "Generated on ${DateTime.now().toString().split('.')[0]}",
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey600, // Darker grey
                    fontStyle: pw.FontStyle.italic, // Added italic style
                  ),
                ),
              ],
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();

      // Hide loading
      scaffoldMessenger.hideCurrentSnackBar();

      // Try printing/previewing the PDF
      try {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: '$title.pdf',
        );
      } catch (printingError) {
        debugPrint("Printing error: $printingError");

        // Fallback: download on web or save on device
        if (kIsWeb) {
          _downloadPdfOnWeb(pdfBytes, "$title.pdf");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF downloaded successfully')),
            );
          }
        } else {
          final savedFile = await _savePdfToDevice(pdfBytes, "$title.pdf");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF saved to ${savedFile.path}')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("PDF creation error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  /// Web download fallback
  static void _downloadPdfOnWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  /// Save PDF on Android/iOS
  static Future<File> _savePdfToDevice(Uint8List bytes, String fileName) async {
    Directory? directory; // Make directory nullable
    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!(await directory.exists())) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        directory = await getTemporaryDirectory();
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint("File save error: $e");
      final fallbackDir = await getTemporaryDirectory();
      final tempFile = File('${fallbackDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    }
  }
}

