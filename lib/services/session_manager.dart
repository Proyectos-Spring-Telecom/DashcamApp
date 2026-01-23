import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/widgets/routes/app_routes.dart' as app_routes;
import 'package:dashboardpro/widgets/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/foundation.dart';

/// * Gestor centralizado de sesión
/// Maneja el cierre automático de sesión cuando el token expira
class SessionManager {
  static bool _isLoggingOut = false;

  /// * Verifica si una respuesta indica sesión inválida
  static bool isSessionInvalid(dynamic responseData, int? statusCode) {
    // * Verificar código de estado HTTP
    if (statusCode == 401 || statusCode == 403) {
      return true;
    }

    // * Verificar mensaje en la respuesta
    if (responseData != null) {
      String? message;
      
      if (responseData is Map<String, dynamic>) {
        message = responseData['message']?.toString() ?? 
                  responseData['error']?.toString() ??
                  responseData['mensaje']?.toString();
      } else if (responseData is String) {
        message = responseData;
      }

      if (message != null) {
        final messageLower = message.toLowerCase();
        return messageLower.contains('sesión inválida') ||
               messageLower.contains('session invalid') ||
               messageLower.contains('token expirado') ||
               messageLower.contains('token expired') ||
               messageLower.contains('unauthorized') ||
               messageLower.contains('forbidden');
      }
    }

    return false;
  }

  /// * Maneja el cierre automático de sesión
  /// Cierra sesión, limpia el estado y redirige al login
  static Future<void> handleSessionExpired(BuildContext? context) async {
    // * Evitar múltiples llamadas simultáneas
    if (_isLoggingOut) {
      debugPrint('⚠️ Ya se está procesando un cierre de sesión');
      return;
    }

    _isLoggingOut = true;

    try {
      debugPrint('🔐 Sesión expirada. Cerrando sesión automáticamente...');

      // * Cerrar sesión en AuthBloc primero
      await authBloc.logout();

      // * Obtener contexto para navegación y alerta
      final navigatorContext = context ?? app_routes.rootNavigatorKey.currentContext;

      if (navigatorContext != null && navigatorContext.mounted) {
        try {
          // * Mostrar alerta informativa
          await QuickAlert.show(
            context: navigatorContext,
            type: QuickAlertType.warning,
            title: 'Sesión expirada',
            text: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
            onConfirmBtnTap: () {
              // * Redirigir al login después de cerrar el diálogo
              if (navigatorContext.mounted) {
                GoRouter.of(navigatorContext).go(RoutesName.login);
              }
            },
          );

          // * Redirigir al login después de mostrar la alerta
          if (navigatorContext.mounted) {
            GoRouter.of(navigatorContext).go(RoutesName.login);
          }
        } catch (e) {
          debugPrint('⚠️ Error al mostrar alerta: $e');
          // * Si falla la alerta, redirigir directamente
          if (navigatorContext.mounted) {
            GoRouter.of(navigatorContext).go(RoutesName.login);
          }
        }
      } else {
        // * Si no hay contexto, intentar redirigir usando el navigator key
        debugPrint('⚠️ No hay contexto disponible, intentando redirigir con navigator key');
        // * Esperar un momento para que el contexto esté disponible
        await Future.delayed(const Duration(milliseconds: 300));
        
        final routerContext = app_routes.rootNavigatorKey.currentContext;
        if (routerContext != null && routerContext.mounted) {
          try {
            GoRouter.of(routerContext).go(RoutesName.login);
          } catch (e) {
            debugPrint('⚠️ Error al redirigir con GoRouter: $e');
          }
        } else {
          debugPrint('⚠️ No se pudo obtener contexto para redirigir');
        }
      }

      debugPrint('✅ Sesión cerrada y redirigido al login');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al manejar expiración de sesión: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      _isLoggingOut = false;
    }
  }
}
