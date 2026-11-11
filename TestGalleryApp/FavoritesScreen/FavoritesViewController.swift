import UIKit

// MARK: - FavoritesViewController
final class FavoritesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: FavoritesViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Init
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigation() {
        title = "Favorites"
    }
    
    // MARK: - Layout
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 3.0),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1.0 / 3.0)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onFavoritesUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.onError = { [weak self] message in
            self?.presentError(message)
        }
    }
    
    // MARK: - Error Handling
    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    private func openDetail(at indexPath: IndexPath) {
        let photos = viewModel.favorites.map { favorite in
            Photo(
                id: favorite.id,
                description: favorite.title,
                altDescription: nil,
                urls: PhotoUrls(
                    regular: favorite.regularURL,
                    thumb: favorite.thumbURL
                )
            )
        }
        let detailViewModel = DetailViewModel(
            photos: photos,
            initialIndex: indexPath.item,
            isReadOnly: false
        )
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoriteCell.identifier,
            for: indexPath
        ) as? FavoriteCell,
              viewModel.favorites.indices.contains(indexPath.item) else {
            return UICollectionViewCell()
        }
        let favorite = viewModel.favorites[indexPath.item]
        cell.configure(with: favorite, isFavorite: viewModel.isFavorite(id: favorite.id))
        cell.onFavoriteTapped = { [weak self] in
            self?.viewModel.toggleFavorite(id: favorite.id)
            guard let currentCell = collectionView.cellForItem(at: indexPath) as? FavoriteCell else { return }
            currentCell.updateFavoriteAppearance(isFavorite: self?.viewModel.isFavorite(id: favorite.id) ?? false)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel.favorites.indices.contains(indexPath.item) else { return }
        openDetail(at: indexPath)
    }
}
