// lib/utils/logger.dart

import 'package:logging/logging.dart';

final Logger logger = Logger('M1G1R2App');

void setupLogger() {
  Logger.root.level = Level.ALL; // Set to desired level
  Logger.root.onRecord.listen((record) {
    // Customize logging output as needed
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: ${record.stackTrace}');
    }
  });
}
