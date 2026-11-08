import CoreData
import OSLog

// MARK: - FavoritesRepositoryProtocol
protocol FavoritesRepositoryProtocol {
    func save(photo: Photo) throws
    func remove(id: String) throws
    func fetchAll() throws -> [FavoritePhoto]
    func isFavorite(id: String) -> Bool
}

// MARK: - FavoritesRepository
final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(photo: Photo) throws {
        let entity = FavoritePhotoEntity(context: context)
        entity.id = photo.id
        entity.thumbURL = photo.urls.thumb
        entity.regularURL = photo.urls.regular
        entity.title = photo.description ?? photo.altDescription
        entity.dateAdded = Date()
        try context.save()
        Logger.persistence.info("[\(Self.self)] Saved favorite: \(photo.id, privacy: .public)")
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    func remove(id: String) throws {
        let entities = try fetchEntities()
        guard let entity = entities.first(where: { $0.id == id }) else { return }
        context.delete(entity)
        try context.save()
        Logger.persistence.info("[\(Self.self)] Removed favorite: \(id, privacy: .public)")
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    func fetchAll() throws -> [FavoritePhoto] {
        let entities = try fetchEntities()
        return entities.compactMap { entity in
            guard let id = entity.id,
                  let thumbURL = entity.thumbURL,
                  let regularURL = entity.regularURL else {
                return nil
            }
            return FavoritePhoto(
                id: id,
                thumbURL: thumbURL,
                regularURL: regularURL,
                title: entity.title
            )
        }
    }
    
    func isFavorite(id: String) -> Bool {
        (try? fetchEntities().contains(where: { $0.id == id })) ?? false
    }
    
    private func fetchEntities() throws -> [FavoritePhotoEntity] {
        let request = FavoritePhotoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        return try context.fetch(request)
    }
}

// MARK: - Notification
extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}
