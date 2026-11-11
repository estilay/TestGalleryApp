import UIKit

// MARK: - DetailViewController
final class DetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: DetailViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DetailPhotoCell.self, forCellWithReuseIdentifier: DetailPhotoCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var heartFillView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var heartOutlineView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "heart")
        imageView.tintColor = .black
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Init
    init(viewModel: DetailViewModel) {
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
        bindViewModel()
        setupNotification()
        updateFavoriteAppearance()
        scrollToInitialIndex()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(favoriteButton)
        view.addSubview(descriptionLabel)
        
        favoriteButton.addSubview(heartFillView)
        favoriteButton.addSubview(heartOutlineView)
        
        favoriteButton.isHidden = viewModel.isReadOnly
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            favoriteButton.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),
            
            heartFillView.topAnchor.constraint(equalTo: favoriteButton.topAnchor),
            heartFillView.leadingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            heartFillView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            heartFillView.bottomAnchor.constraint(equalTo: favoriteButton.bottomAnchor),
            
            heartOutlineView.topAnchor.constraint(equalTo: favoriteButton.topAnchor),
            heartOutlineView.leadingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            heartOutlineView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            heartOutlineView.bottomAnchor.constraint(equalTo: favoriteButton.bottomAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onFavoriteChanged = { [weak self] in
            self?.updateFavoriteAppearance()
            self?.updateDescription()
        }
        viewModel.onPhotosUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: - Notification
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidChange),
            name: .favoritesDidChange,
            object: nil
        )
    }

    @objc
    private func favoritesDidChange() {
        updateFavoriteAppearance()
    }
    
    private func scrollToInitialIndex() {
        let indexPath = IndexPath(item: viewModel.currentIndex, section: 0)
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        updateDescription()
    }
    
    private func updateDescription() {
        descriptionLabel.text = viewModel.currentDescription
    }
    
    private func updateFavoriteAppearance() {
        let isFavorite = viewModel.isFavorite(id: viewModel.currentPhoto.id)
        if isFavorite {
            heartFillView.tintColor = .systemRed
            heartOutlineView.tintColor = .systemRed
        } else {
            heartFillView.tintColor = .white
            heartOutlineView.tintColor = .black
        }
    }
    
    // MARK: - Actions
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}

// MARK: - UICollectionViewDataSource
extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailPhotoCell.identifier,
            for: indexPath
        ) as? DetailPhotoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.photos[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        viewModel.updateCurrentIndex(page)
        updateDescription()
        Task {
            await viewModel.loadMoreIfNeeded(currentIndex: page)
        }
    }
}
