import Foundation
import OSLog

// MARK: - ImagesFetchServiceProtocol
protocol ImagesFetchServiceProtocol {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo]
}

// MARK: - ImagesFetchService
final class ImagesFetchService: ImagesFetchServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.unsplash.com"
    private let accessKey = AppConfig.unsplashAPIKey

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
        guard !accessKey.isEmpty else {
            Logger.network.error("[\(Self.self)] API key missing")
            throw NetworkError.noAPIKey
        }

        var components = URLComponents(string: "\(baseURL)/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components?.url else {
            Logger.network.error("[\(Self.self)] Invalid URL for page \(page)")
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            Logger.network.error("[\(Self.self)] Request failed: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.urlRequestError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.network.error("[\(Self.self)] Invalid response type")
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            Logger.network.error("[\(Self.self)] HTTP \(httpResponse.statusCode)")
            throw NetworkError.httpStatusCode(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            
            let photos = try decoder.decode([Photo].self, from: data)
            Logger.network.info("[\(Self.self)] Fetched \(photos.count) photos, page \(page)")
            
            return photos
        } catch {
            Logger.network.error("[\(Self.self)] Decoding failed: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.decodingError(error)
        }
    }
}
