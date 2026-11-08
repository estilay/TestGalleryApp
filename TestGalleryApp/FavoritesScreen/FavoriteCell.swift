import UIKit
import Kingfisher

// MARK: - FavoriteCellDelegate
protocol FavoriteCellDelegate: AnyObject {
    func favoriteCellDidRequestDelete(_ cell: FavoriteCell)
}

// MARK: - FavoriteCell
final class FavoriteCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "FavoriteCell"

    weak var delegate: FavoriteCellDelegate?

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

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupContextMenu()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        isUserInteractionEnabled = true
    }

    // MARK: - Configure
    func configure(with favorite: FavoritePhoto) {
        let url = URL(string: favorite.thumbURL)
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        delegate = nil
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension FavoriteCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            let deleteAction = UIAction(
                title: "Remove from Favorites",
                attributes: .destructive
            ) { _ in
                self.delegate?.favoriteCellDidRequestDelete(self)
            }
            return UIMenu(children: [deleteAction])
        }
    }
}
