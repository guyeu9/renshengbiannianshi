sealed class AppError implements Exception {
  const AppError(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  String get userFriendlyMessage;
}

class DatabaseError extends AppError {
  const DatabaseError(super.message, {super.stackTrace});

  @override
  String get userFriendlyMessage => '数据库操作失败，请重试';
}

class NetworkError extends AppError {
  const NetworkError(super.message, {super.stackTrace});

  @override
  String get userFriendlyMessage => '网络连接失败，请检查网络设置';
}

class StorageError extends AppError {
  const StorageError(super.message, {super.stackTrace});

  @override
  String get userFriendlyMessage => '存储操作失败，请检查存储空间';
}

class PermissionError extends AppError {
  const PermissionError(super.message, {super.stackTrace});

  @override
  String get userFriendlyMessage => '权限不足，请在设置中授权';
}

class ValidationError extends AppError {
  const ValidationError(super.message, {super.stackTrace});

  @override
  String get userFriendlyMessage => message;
}

class UnknownError extends AppError {
  const UnknownError(super.message, {super.stackTrace});

  @override
  String get userFriendlyMessage => '发生未知错误，请重试';
}

extension ErrorExtension on Object {
  AppError toAppError() {
    final errorString = toString();

    if (errorString.contains('database') ||
        errorString.contains('sqlite') ||
        errorString.contains('drift')) {
      return DatabaseError(errorString);
    }

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return NetworkError(errorString);
    }

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return PermissionError(errorString);
    }

    if (errorString.contains('storage') || errorString.contains('file')) {
      return StorageError(errorString);
    }

    return UnknownError(errorString);
  }
}
