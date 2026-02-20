import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'life_chronicle.sqlite'));
    final existing = await file.exists();
    final existingSize = existing ? await file.length() : 0;
    if (!existing || existingSize == 0) {
      final candidates = <String>[
        'life_chronicle.db',
        'app.sqlite',
        'app.db',
      ];
      for (final name in candidates) {
        final legacy = File(p.join(dir.path, name));
        if (await legacy.exists()) {
          try {
            await legacy.rename(file.path);
          } catch (_) {
            await legacy.copy(file.path);
          }
          break;
        }
      }
    }
    return NativeDatabase.createInBackground(file);
  });
}
