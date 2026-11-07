import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.example.testGalleryApp"
    
    static let network = Logger(subsystem: subsystem, category: "Network")

    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    
    static let imageLoading = Logger(subsystem: subsystem, category: "ImageLoading")
}
