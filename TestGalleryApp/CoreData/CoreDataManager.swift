import CoreData
import OSLog

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        
    }
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GalleryModel")
        container.loadPersistentStores { _, error in
            if let error {
                Logger.persistence.error("[\(Self.self)] Failed to load stores: \(error.localizedDescription, privacy: .public)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            Logger.persistence.error("[\(Self.self)] Failed to save context: \(error.localizedDescription, privacy: .public)")
        }
    }
}
