import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load Google Maps API key from .env file
    if let path = Bundle.main.path(forResource: ".env", ofType: nil),
       let contents = try? String(contentsOfFile: path, encoding: .utf8) {
      let lines = contents.components(separatedBy: .newlines)
      for line in lines {
        if line.hasPrefix("MAPS_API_KEY=") {
          let apiKey = line.replacingOccurrences(of: "MAPS_API_KEY=", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
          if !apiKey.isEmpty && !apiKey.contains("your_") {
            GMSServices.provideAPIKey(apiKey)
            print("✅ Google Maps API key loaded successfully")
          } else {
            print("⚠️ Google Maps API key not configured in .env file")
          }
          break
        }
      }
    } else {
      print("⚠️ .env file not found - Google Maps may not work")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
