import Flutter
import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Obtener la clave de API de Google Maps desde Info.plist o variable de entorno
    let apiKey: String
    if let infoPlistKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !infoPlistKey.isEmpty && !infoPlistKey.contains("$(GOOGLE_MAPS_API_KEY)") {
      // Si Info.plist tiene un valor real (no el placeholder), usarlo
      apiKey = infoPlistKey
    } else if let envKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"],
              !envKey.isEmpty {
      // Si hay una variable de entorno, usarla
      apiKey = envKey
    } else {
      // Fallback: intentar leer desde Info.plist (puede estar configurado por el build system)
      apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
      if apiKey.isEmpty {
        fatalError("ERROR: GOOGLE_MAPS_API_KEY no encontrada. Define la variable de entorno GOOGLE_MAPS_API_KEY o configura GOOGLE_MAPS_API_KEY en ios/Flutter/GoogleMapsApiKey.xcconfig")
      }
    }
    
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
