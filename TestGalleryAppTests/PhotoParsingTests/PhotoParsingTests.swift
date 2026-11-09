import XCTest
@testable import TestGalleryApp

final class PhotoParsingTests: XCTestCase {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private func decodeSamplePhotos() throws -> [Photo] {
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(bundle.url(forResource: "photo_sample", withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try decoder.decode([Photo].self, from: data)
    }
    
    func testPhotoParsing() throws {
        let photos = try decodeSamplePhotos()
        
        XCTAssertFalse(photos.isEmpty)
        XCTAssertFalse(photos[0].id.isEmpty)
        XCTAssertFalse(photos[0].urls.regular.isEmpty)
        XCTAssertFalse(photos[0].urls.thumb.isEmpty)
    }
    
    func testPhotoParsingAltDescription() throws {
        let photos = try decodeSamplePhotos()
        
        XCTAssertNotNil(photos[0].altDescription)
    }
}
