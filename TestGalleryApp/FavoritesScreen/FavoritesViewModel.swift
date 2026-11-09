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

    func removeFavorite(at index: Int) {
        guard favorites.indices.contains(index) else { return }
        let favorite = favorites[index]
        do {
            try repository.remove(id: favorite.id)
            favorites.remove(at: index)
            onFavoritesUpdated?()
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to remove favorite: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }
}
