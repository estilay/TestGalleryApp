import Foundation

enum AppConfig {
    static var unsplashAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_KEY") as? String,
              !key.isEmpty,
              !key.hasPrefix("$(") else {
            return ""
        }
        return key
    }
}
