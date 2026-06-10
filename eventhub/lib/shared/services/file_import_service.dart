import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class ImportResult {
  final List<Map<String, String>> entries;
  final List<String> errors;
  final int totalRows;
  final int validRows;

  ImportResult({
    required this.entries,
    required this.errors,
    required this.totalRows,
    required this.validRows,
  });
}

class FileImportService {
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    return result?.files.first;
  }

  Future<ImportResult> importInvitations(PlatformFile file) async {
    final ext = file.extension?.toLowerCase() ?? '';
    if (ext == 'csv') {
      return _importCsv(file);
    }
    return ImportResult(
      entries: [],
      errors: ['Unsupported file format: .$ext. Please use CSV files.'],
      totalRows: 0,
      validRows: 0,
    );
  }

  Future<ImportResult> _importCsv(PlatformFile file) async {
    final errors = <String>[];
    final entries = <Map<String, String>>[];
    final content = await File(file.path!).readAsString();
    final rows = const CsvToListConverter().convert(content);

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || (row.length == 1 && '${row[0]}'.trim().isEmpty)) {
        continue;
      }
      final email = row.isNotEmpty ? '${row[0]}'.trim() : '';
      final name = row.length > 1 ? '${row[1]}'.trim() : '';
      if (email.isEmpty || !_isValidEmail(email)) {
        errors.add('Row ${i + 1}: invalid email "$email"');
        continue;
      }
      entries.add({'email': email, 'name': name});
    }

    return ImportResult(
      entries: entries,
      errors: errors,
      totalRows: rows.length,
      validRows: entries.length,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.\w+').hasMatch(email);
  }
}
