import 'dart:async';

import 'package:flutter/material.dart';
import 'package:life_chronicle/core/errors/app_error.dart';
import 'package:life_chronicle/core/errors/error_handler.dart';

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  final Widget child;
  final void Function(AppError error)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;
  StreamSubscription<AppError>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _errorSubscription = ErrorHandler.instance.errorStream.listen(_handleError);
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  void _handleError(AppError error) {
    if (!mounted) return;
    widget.onError?.call(error);
    setState(() {
      _error = error;
    });
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorWidget(
        error: _error!,
        onRetry: _retry,
      );
    }
    return widget.child;
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.userFriendlyMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    return switch (error) {
      DatabaseError() => Icons.storage_outlined,
      NetworkError() => Icons.wifi_off_outlined,
      StorageError() => Icons.sd_storage_outlined,
      PermissionError() => Icons.lock_outline,
      ValidationError() => Icons.warning_amber_outlined,
      UnknownError() => Icons.error_outline,
    };
  }
}

class ErrorSnackBar {
  static void show(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userFriendlyMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '关闭',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
