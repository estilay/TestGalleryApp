import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case decodingError(Error)
    case noAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .invalidResponse: "Invalid response"
        case .httpStatusCode(let code): "HTTP error: \(code)"
        case .urlRequestError(let error): "Request failed: \(error.localizedDescription)"
        case .decodingError(let error): "Decoding failed: \(error.localizedDescription)"
        case .noAPIKey: "API key not configured"
        }
    }
}
