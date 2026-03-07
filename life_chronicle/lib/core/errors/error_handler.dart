import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:life_chronicle/core/errors/app_error.dart';

class ErrorHandler {
  ErrorHandler._();

  static final ErrorHandler instance = ErrorHandler._();

  void handleError(Object error, StackTrace stackTrace) {
    final appError = error is AppError ? error : error.toAppError();

    if (kDebugMode) {
      debugPrint('=== Error ===');
      debugPrint('Type: ${appError.runtimeType}');
      debugPrint('Message: ${appError.message}');
      debugPrint('User Message: ${appError.userFriendlyMessage}');
      if (appError.stackTrace != null) {
        debugPrint('Stack Trace:\n${appError.stackTrace}');
      }
      debugPrint('=============');
    }

    _errorController.add(appError);
  }

  final _errorController = StreamController<AppError>.broadcast();

  Stream<AppError> get errorStream => _errorController.stream;

  void dispose() {
    _errorController.close();
  }
}

typedef ErrorCallback = void Function(AppError error);

mixin ErrorHandlerMixin<T> {
  Future<T?> withErrorHandling(
    Future<T> Function() action, {
    ErrorCallback? onError,
    T Function()? orElse,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final appError = error is AppError ? error : error.toAppError();
      ErrorHandler.instance.handleError(error, stackTrace);
      onError?.call(appError);
      return orElse?.call();
    }
  }

  Stream<T> withStreamErrorHandling(
    Stream<T> Function() action, {
    ErrorCallback? onError,
  }) {
    return action().handleError((error, stackTrace) {
      final appError = error is AppError ? error : error.toAppError();
      ErrorHandler.instance.handleError(error, stackTrace);
      onError?.call(appError);
    });
  }
}
