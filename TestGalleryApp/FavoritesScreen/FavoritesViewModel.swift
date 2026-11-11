import Foundation
import OSLog

// MARK: - FavoritesViewModel
final class FavoritesViewModel {
    // MARK: - Properties
    private let repository: FavoritesRepositoryProtocol

    private(set) var favorites: [FavoritePhoto] = []
    private(set) var isLoading = false

    var onFavoritesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Init
    init(repository: FavoritesRepositoryProtocol = FavoritesRepository()) {
        self.repository = repository
    }

    // MARK: - Public Methods
    func loadFavorites() {
        isLoading = true
        defer { isLoading = false }

        do {
            favorites = try repository.fetchAll()
            onFavoritesUpdated?()
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to load favorites: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }

    func isFavorite(id: String) -> Bool {
        repository.isFavorite(id: id)
    }

    func toggleFavorite(id: String) {
        guard let favorite = favorites.first(where: { $0.id == id }) else { return }
        do {
            if repository.isFavorite(id: id) {
                try repository.remove(id: id)
            } else {
                let photo = Photo(
                    id: favorite.id,
                    description: favorite.title,
                    altDescription: nil,
                    urls: PhotoUrls(
                        regular: favorite.regularURL,
                        thumb: favorite.thumbURL
                    )
                )
                try repository.save(photo: photo)
            }
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to toggle favorite: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }
}
