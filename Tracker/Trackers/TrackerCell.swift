import UIKit

final class TrackerCell: UICollectionViewCell {

    // MARK: - Constants
    static let reuseId = "TrackerCell"

    // MARK: - Nested types
    struct ViewModel {
        let name: String
        let emoji: String
        let color: UIColor
        let daysText: String
        let isCompletedForSelectedDate: Bool
        let canComplete: Bool
        let isPinned: Bool
    }

    // MARK: - UI
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.emojiFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primaryBackground.withAlphaComponent(0.3)
        view.layer.cornerRadius = Constants.emojiBackgroundCornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        label.textColor = AppColors.primaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pinImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .pin)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = Constants.completeButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViewHierarchy()
        setupConstraints()
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        emojiLabel.text = nil
        daysLabel.text = nil
        cardView.backgroundColor = nil
        completeButton.backgroundColor = nil
        completeButton.setImage(nil, for: .normal)
        pinImageView.isHidden = true
        onCompleteTapped = nil
    }

    // MARK: - Callbacks
    var onCompleteTapped: (() -> Void)?

    var previewView: UIView { cardView }

    // MARK: - Public
    func configure(viewModel: ViewModel) {
        titleLabel.text = viewModel.name
        emojiLabel.text = viewModel.emoji
        cardView.backgroundColor = viewModel.color
        completeButton.tintColor = viewModel.color
        daysLabel.text = viewModel.daysText
        let image = viewModel.isCompletedForSelectedDate ? UIImage(resource: .doneButton) : UIImage(resource: .plusButton)
        completeButton.setImage(image, for: .normal)
        completeButton.alpha = viewModel.canComplete ? 1 : 0.3
        completeButton.isEnabled = viewModel.canComplete
        pinImageView.isHidden = !viewModel.isPinned
    }

    // MARK: - Actions
    @objc private func completeButtonTapped() {
        onCompleteTapped?()
    }

    // MARK: - Private
    private func setupViewHierarchy() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackgroundView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(pinImageView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: Constants.cardHeight),

            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.cardPadding),
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Constants.cardPadding),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: Constants.emojiBackgroundSize),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: Constants.emojiBackgroundSize),

            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.cardPadding),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.cardPadding),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Constants.cardPadding),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: Constants.completeButtonTopSpacing),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cardPadding),
            completeButton.widthAnchor.constraint(equalToConstant: Constants.completeButtonSize),
            completeButton.heightAnchor.constraint(equalToConstant: Constants.completeButtonSize),

            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cardPadding),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Constants.cardPadding),
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.pinPadding),
            pinImageView.widthAnchor.constraint(equalToConstant: Constants.pinIconSize),
            pinImageView.heightAnchor.constraint(equalToConstant: Constants.pinIconSize)
        ])
    }

}

// MARK: - Constants
private extension TrackerCell {
    enum Constants {
        static let cardHeight: CGFloat = 90
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 12
        static let pinPadding: CGFloat = 4
        static let emojiBackgroundSize: CGFloat = 24
        static let emojiBackgroundCornerRadius: CGFloat = 12
        static let emojiFontSize: CGFloat = 14
        static let labelFontSize: CGFloat = 12
        static let completeButtonSize: CGFloat = 34
        static let completeButtonCornerRadius: CGFloat = 17
        static let completeButtonTopSpacing: CGFloat = 8
        static let pinIconSize: CGFloat = 24
    }
}
