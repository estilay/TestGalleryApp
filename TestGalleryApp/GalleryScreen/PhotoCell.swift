import UIKit
import Kingfisher

// MARK: - PhotoCell
final class PhotoCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "PhotoCell"

    var onFavoriteTapped: (() -> Void)?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
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

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteButton)
        favoriteButton.addSubview(heartFillView)
        favoriteButton.addSubview(heartOutlineView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            heartFillView.topAnchor.constraint(equalTo: favoriteButton.topAnchor),
            heartFillView.leadingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            heartFillView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            heartFillView.bottomAnchor.constraint(equalTo: favoriteButton.bottomAnchor),

            heartOutlineView.topAnchor.constraint(equalTo: favoriteButton.topAnchor),
            heartOutlineView.leadingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            heartOutlineView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            heartOutlineView.bottomAnchor.constraint(equalTo: favoriteButton.bottomAnchor)
        ])
    }

    // MARK: - Configure
    func configure(with photo: Photo, isFavorite: Bool) {
        updateFavoriteAppearance(isFavorite: isFavorite)

        let url = URL(string: photo.urls.thumb)
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }

    func setFavorite(_ isFavorite: Bool) {
        updateFavoriteAppearance(isFavorite: isFavorite)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        updateFavoriteAppearance(isFavorite: false)
        onFavoriteTapped = nil
    }

    // MARK: - Private
    private func updateFavoriteAppearance(isFavorite: Bool) {
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
        onFavoriteTapped?()
    }
}
