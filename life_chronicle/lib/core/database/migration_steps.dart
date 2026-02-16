import 'package:drift/drift.dart';

typedef MigrationStep = Future<void> Function(Migrator m);

Future<void> runMigrationSteps(
  Migrator m,
  int from,
  int to, {
  required Map<int, MigrationStep> steps,
}) async {
  for (var v = from + 1; v <= to; v++) {
    final step = steps[v];
    if (step != null) {
      await step(m);
    }
  }
}
