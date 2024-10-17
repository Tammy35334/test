// lib/utils/logger.dart

import 'package:logging/logging.dart';

final Logger logger = Logger('MyApp');

void setupLogger() {
  Logger.root.level = Level.ALL; // Set the desired logging level
  Logger.root.onRecord.listen((record) {
    // Customize the log output as needed
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });
}
