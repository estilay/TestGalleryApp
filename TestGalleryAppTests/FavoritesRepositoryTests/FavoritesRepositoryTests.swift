import XCTest
import CoreData
@testable import TestGalleryApp

final class FavoritesRepositoryTests: XCTestCase {
    var container: NSPersistentContainer!
    var repository: FavoritesRepository!

    override func setUpWithError() throws {
        container = NSPersistentContainer(name: "GalleryModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        repository = FavoritesRepository(context: container.viewContext)
    }

    override func tearDown() {
        repository = nil
        container = nil
        super.tearDown()
    }

    func testSaveAndFetch() throws {
        // Given
        let photo = Photo(
            id: "test1",
            description: "Test",
            altDescription: "Alt",
            urls: PhotoUrls(regular: "r", thumb: "t")
        )

        // When
        try repository.save(photo: photo)
        let favorites = try repository.fetchAll()

        // Then
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites[0].id, "test1")
    }

    func testIsFavorite() throws {
        // Given
        let photo = Photo(
            id: "test2",
            description: nil,
            altDescription: nil,
            urls: PhotoUrls(regular: "r", thumb: "t")
        )

        // When
        let isFavoriteBeforeSave = repository.isFavorite(id: "test2")
        try repository.save(photo: photo)
        let isFavoriteAfterSave = repository.isFavorite(id: "test2")

        // Then
        XCTAssertFalse(isFavoriteBeforeSave)
        XCTAssertTrue(isFavoriteAfterSave)
    }
}
