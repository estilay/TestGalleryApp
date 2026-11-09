import Foundation
import OSLog

// MARK: - DetailViewModel
final class DetailViewModel {
    // MARK: - Properties
    private let repository: FavoritesRepositoryProtocol
    private let galleryViewModel: GalleryViewModel?
    
    private(set) var photos: [Photo]
    private(set) var currentIndex: Int
    let isReadOnly: Bool
    
    var onFavoriteChanged: (() -> Void)?
    var onPhotosUpdated: (() -> Void)?
    
    var currentPhoto: Photo {
        photos[currentIndex]
    }
    
    var currentDescription: String? {
        currentPhoto.description ?? currentPhoto.altDescription
    }
    // MARK: - Init
    init(
        photos: [Photo],
        initialIndex: Int,
        repository: FavoritesRepositoryProtocol = FavoritesRepository(),
        galleryViewModel: GalleryViewModel? = nil,
        isReadOnly: Bool = false
    ) {
        self.photos = photos
        self.currentIndex = initialIndex
        self.repository = repository
        self.galleryViewModel = galleryViewModel
        self.isReadOnly = isReadOnly
    }
    
    // MARK: - Public Methods
    func updateCurrentIndex(_ index: Int) {
        guard photos.indices.contains(index) else { return }
        currentIndex = index
        onFavoriteChanged?()
    }
    
    func loadMoreIfNeeded(currentIndex: Int) async {
        guard let galleryViewModel else { return }
        guard currentIndex >= photos.count - 3 else { return }
        await galleryViewModel.loadNextPage()
        photos = galleryViewModel.photos
        onPhotosUpdated?()
    }
    
    func isFavorite(id: String) -> Bool {
        repository.isFavorite(id: id)
    }
    
    func toggleFavorite() {
        guard !isReadOnly else { return }
        let photo = currentPhoto
        do {
            if repository.isFavorite(id: photo.id) {
                try repository.remove(id: photo.id)
            } else {
                try repository.save(photo: photo)
            }
            onFavoriteChanged?()
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to toggle favorite: \(error.localizedDescription, privacy: .public)")
        }
    }
}
