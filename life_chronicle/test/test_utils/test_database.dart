import 'package:drift/native.dart';
import 'package:life_chronicle/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.connect(NativeDatabase.memory());
}

Future<void> closeTestDatabase(AppDatabase db) async {
  await db.close();
}
