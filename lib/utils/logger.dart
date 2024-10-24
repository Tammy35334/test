// lib/utils/logger.dart

import 'package:logging/logging.dart';

final Logger logger = Logger('M1G1R2App');

void setupLogger() {
  Logger.root.level = Level.ALL; // Set to desired level
  Logger.root.onRecord.listen((record) {
    // Customize logging output as needed
    // Removed 'print' statements to avoid linter warnings
    // Implement your own logging sinks here if necessary
    // For example, you could write to a file or send logs to a remote server
    // Currently, logs are not outputted anywhere
  });
}
