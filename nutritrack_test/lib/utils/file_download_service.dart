import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;

class FileDownloadService {
  static Future<void> saveAndOpenPdf(pw.Document pdf, String fileName) async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }

    // Get directory
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');

    // Save file
    await file.writeAsBytes(await pdf.save());

    // Open file
    await OpenFile.open(file.path);
  }
}
