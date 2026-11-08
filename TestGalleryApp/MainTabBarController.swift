import UIKit

// MARK: - MainTabBarController
final class MainTabBarController: UITabBarController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }

    private func setupViewControllers() {
        let galleryViewModel = GalleryViewModel()
        let galleryViewController = GalleryViewController(viewModel: galleryViewModel)
        let favoritesViewModel = FavoritesViewModel()
        let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
        
        let galleryNav = UINavigationController(rootViewController: galleryViewController)
        let favoritesNav = UINavigationController(rootViewController: favoritesViewController)

        galleryNav.tabBarItem = UITabBarItem(
            title: "Gallery",
            image: UIImage(systemName: "photo.on.rectangle"),
            selectedImage: UIImage(systemName: "photo.fill")
        )

        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        viewControllers = [galleryNav, favoritesNav]
    }
}
