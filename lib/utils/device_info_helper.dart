import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

// Conditional import para dart:html solo en web
import 'device_info_helper_stub.dart' if (dart.library.html) 'device_info_helper_web.dart' as html_stub;

/// Helper para obtener información del dispositivo
/// Compatible con Web, iOS, Android y otras plataformas
class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Obtiene toda la información del dispositivo en formato similar al ejemplo
  static Future<Map<String, dynamic>> getDeviceInformation(
      BuildContext? context) async {
    if (kIsWeb) {
      return await _getWebDeviceInformation(context);
    }
    
    // Solo usar Platform en plataformas no-web
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceInformation();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceInformation();
      }
    } catch (e) {
      // Si hay error al detectar la plataforma, retornar información por defecto
      debugPrint('⚠️ Error al detectar plataforma: $e');
    }
    
    return _getDefaultDeviceInformation();
  }

  /// Obtiene información del dispositivo para Web
  static Future<Map<String, dynamic>> _getWebDeviceInformation(
      BuildContext? context) async {
    try {
      final webInfo = await _deviceInfo.webBrowserInfo;
      
      // Obtener información de pantalla desde MediaQuery si está disponible
      double screenWidth = 0;
      double screenHeight = 0;
      int colorDepth = 24;
      
      if (context != null) {
        final mediaQuery = MediaQuery.of(context);
        screenWidth = mediaQuery.size.width;
        screenHeight = mediaQuery.size.height;
      }

      // Obtener información del navegador usando dart:html
      String language = 'es';
      bool javaEnabled = false;
      bool javaScriptEnabled = true; // Siempre true en Flutter web
      int timeDifference = 0;

      if (kIsWeb) {
        try {
          // Usar conditional import para dart:html solo en web
          final browserInfo = html_stub.BrowserInfoHelper.getBrowserInfo();
          language = browserInfo['language'] ?? 'es';
          javaEnabled = browserInfo['javaEnabled'] ?? false;
          timeDifference = browserInfo['timeDifference'] ?? 0;
          
          // Obtener dimensiones de pantalla desde window.screen si está disponible
          if (screenWidth == 0 || screenHeight == 0) {
            screenWidth = browserInfo['screenWidth']?.toDouble() ?? 0;
            screenHeight = browserInfo['screenHeight']?.toDouble() ?? 0;
          }
          colorDepth = browserInfo['colorDepth'] ?? 24;
        } catch (e) {
          // Si falla, usar valores por defecto
          debugPrint('⚠️ No se pudo obtener información completa del navegador: $e');
        }
      }

      return {
        'deviceChannel': 'Browser',
        'httpBrowserColorDepth': colorDepth.toString(),
        'httpBrowserJavaEnabled': javaEnabled ? 'TRUE' : 'FALSE',
        'httpBrowserJavaScriptEnabled': javaScriptEnabled ? 'TRUE' : 'FALSE',
        'httpBrowserLanguage': language,
        'httpBrowserScreenHeight': screenHeight.toInt().toString(),
        'httpBrowserScreenWidth': screenWidth.toInt().toString(),
        'httpBrowserTimeDifference': timeDifference.toString(),
        // Información adicional del dispositivo web
        'browserName': webInfo.browserName.name,
        'userAgent': webInfo.userAgent ?? '',
        'vendor': webInfo.vendor ?? '',
        'vendorSub': webInfo.vendorSub ?? '',
        'platform': webInfo.platform ?? '',
        'hardwareConcurrency': webInfo.hardwareConcurrency?.toString() ?? '0',
      };
    } catch (e) {
      debugPrint('❌ Error al obtener información del dispositivo web: $e');
      return _getDefaultDeviceInformation();
    }
  }

  /// Obtiene información del dispositivo Android
  static Future<Map<String, dynamic>> _getAndroidDeviceInformation() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      
      return {
        'deviceChannel': 'Mobile',
        'deviceId': androidInfo.id,
        'deviceModel': androidInfo.model,
        'deviceManufacturer': androidInfo.manufacturer,
        'deviceBrand': androidInfo.brand,
        'deviceProduct': androidInfo.product,
        'deviceHardware': androidInfo.hardware,
        'osVersion': 'Android ${androidInfo.version.release}',
        'osSdkInt': androidInfo.version.sdkInt.toString(),
        'osCodename': androidInfo.version.codename ?? '',
        'osIncremental': androidInfo.version.incremental ?? '',
        'isPhysicalDevice': androidInfo.isPhysicalDevice.toString(),
        'systemFeatures': androidInfo.systemFeatures.join(','),
      };
    } catch (e) {
      debugPrint('❌ Error al obtener información del dispositivo Android: $e');
      return _getDefaultDeviceInformation();
    }
  }

  /// Obtiene información del dispositivo iOS
  static Future<Map<String, dynamic>> _getIOSDeviceInformation() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;
      
      return {
        'deviceChannel': 'Mobile',
        'deviceId': iosInfo.identifierForVendor ?? '',
        'deviceName': iosInfo.name,
        'deviceModel': iosInfo.model,
        'deviceUtsname': {
          'machine': iosInfo.utsname.machine,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'sysname': iosInfo.utsname.sysname,
          'version': iosInfo.utsname.version,
        },
        'osVersion': 'iOS ${iosInfo.systemVersion}',
        'isPhysicalDevice': iosInfo.isPhysicalDevice.toString(),
        'localizedModel': iosInfo.localizedModel ?? '',
      };
    } catch (e) {
      debugPrint('❌ Error al obtener información del dispositivo iOS: $e');
      return _getDefaultDeviceInformation();
    }
  }

  /// Retorna información por defecto si no se puede obtener la específica
  static Map<String, dynamic> _getDefaultDeviceInformation() {
    return {
      'deviceChannel': 'Unknown',
      'error': 'No se pudo obtener información del dispositivo',
    };
  }
}
