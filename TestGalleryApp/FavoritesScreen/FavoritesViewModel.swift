import Foundation
import OSLog

// MARK: - FavoritesViewModel
final class FavoritesViewModel {
    // MARK: - Properties
    private let repository: FavoritesRepositoryProtocol

    private(set) var favorites: [FavoritePhoto] = []
    private(set) var isLoading = false

    var onFavoritesUpdated: (() -> Void)?
    var onFavoriteRemoved: ((Int) -> Void)?
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

    func removeFavorite(id: String) {
        guard let index = favorites.firstIndex(where: { $0.id == id }) else { return }
        do {
            try repository.remove(id: id)
            favorites.remove(at: index)
            onFavoriteRemoved?(index)
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to remove favorite: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }
}
