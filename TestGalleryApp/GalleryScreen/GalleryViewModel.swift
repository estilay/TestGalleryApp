import Foundation
import OSLog

// MARK: - GalleryViewModel
final class GalleryViewModel {
    // MARK: - Properties
    private let service: ImagesFetchServiceProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    private(set) var photos: [Photo] = []
    private(set) var isLoading = false
    private var currentPage = 0
    private let perPage = 30

    var onPhotosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Init
    init(
        service: ImagesFetchServiceProtocol = ImagesFetchService(),
        favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository()
    ) {
        self.service = service
        self.favoritesRepository = favoritesRepository
    }

    // MARK: - Public methods
    func loadFirstPage() async {
        guard photos.isEmpty else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        let nextPage = currentPage + 1
        do {
            let newPhotos = try await service.fetchPhotos(page: nextPage, perPage: perPage)
            photos.append(contentsOf: newPhotos)
            currentPage = nextPage
            onPhotosUpdated?()
        } catch {
            Logger.network.error("[\(Self.self)] Pagination failed: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }

    func isFavorite(id: String) -> Bool {
        favoritesRepository.isFavorite(id: id)
    }

    func toggleFavorite(photo: Photo) {
        do {
            if favoritesRepository.isFavorite(id: photo.id) {
                try favoritesRepository.remove(id: photo.id)
            } else {
                try favoritesRepository.save(photo: photo)
            }
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to toggle favorite: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }
}
