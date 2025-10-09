
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class CodeStore {
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/ir_codes.json');
  }

  Future<Map<String, dynamic>> readCodes() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return json.decode(contents);
      } else {
        return _loadDefaultCodes();
      }
    } catch (e) {
      return _loadDefaultCodes();
    }
  }

  Future<Map<String, dynamic>> _loadDefaultCodes() async {
    final String jsonString = await rootBundle.loadString('assets/default_codes.json');
    final codes = json.decode(jsonString);
    await _writeCodes(codes);
    return codes;
  }

  Future<File> _writeCodes(Map<String, dynamic> codes) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(codes));
  }

  Future<void> mergeAndSaveCodes(File newCodesFile) async {
    final existingCodes = await readCodes();
    final newCodesString = await newCodesFile.readAsString();
    final newCodes = json.decode(newCodesString);

    if (newCodes.containsKey('buttons')) {
      final existingButtons = existingCodes['buttons'] as Map<String, dynamic>;
      final newButtons = newCodes['buttons'] as Map<String, dynamic>;

      newButtons.forEach((key, value) {
        if (!existingButtons.containsKey(key)) {
          existingButtons[key] = value;
        }
      });
    }

    await _writeCodes(existingCodes);
  }
}
