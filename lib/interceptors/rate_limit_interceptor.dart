import 'package:dashboardpro/widgets/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

/// Manejo global de HTTP 429 (Too Many Requests).
class RateLimitInterceptor extends Interceptor {
  static const String handledExtraKey = 'rate_limit_handled';

  static bool _alertVisible = false;

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (tryHandle(err, handler)) return;
    handler.next(err);
  }

  /// Retorna `true` si el error 429 fue manejado (log + alert + reject).
  static bool tryHandle(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (err.response?.statusCode != 429) return false;

    _log429(err.requestOptions);
    _showAlertIfNeeded();

    handler.reject(_sanitize(err));
    return true;
  }

  static void _log429(RequestOptions options) {
    if (!kDebugMode) return;
    // Log silenciado en entrega de producción.
  }

  static DioException _sanitize(DioException err) {
    final extra = Map<String, dynamic>.from(err.requestOptions.extra);
    extra[handledExtraKey] = true;

    return DioException(
      requestOptions: err.requestOptions.copyWith(extra: extra),
      response: Response<dynamic>(
        requestOptions: err.requestOptions,
        statusCode: 429,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  static void _showAlertIfNeeded() {
    if (_alertVisible) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    _alertVisible = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alertContext = rootNavigatorKey.currentContext;
      if (alertContext == null || !alertContext.mounted) {
        _alertVisible = false;
        return;
      }

      QuickAlert.show(
        context: alertContext,
        type: QuickAlertType.warning,
        title: 'Demasiados intentos',
        text:
            'Has realizado demasiados intentos en un corto periodo de tiempo. '
            'Espera unos momentos antes de volver a intentarlo.',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
        barrierDismissible: false,
        onConfirmBtnTap: () {
          Navigator.of(alertContext, rootNavigator: true).pop();
          _alertVisible = false;
        },
      );
    });
  }
}
