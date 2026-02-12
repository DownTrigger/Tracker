import UIKit

final class TrackerCell: UICollectionViewCell {

    static let reuseId = "TrackerCell"

    // MARK: - Subviews
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        emojiLabel.text = nil
        daysLabel.text = nil
        cardView.backgroundColor = nil
        completeButton.backgroundColor = nil
        completeButton.setImage(nil, for: .normal)
        onCompleteTapped = nil
    }

    // MARK: - Public
    var onCompleteTapped: (() -> Void)?

    func configure(
        name: String,
        emoji: String,
        color: UIColor,
        daysCount: Int,
        isCompletedForSelectedDate: Bool,
        canComplete: Bool
    ) {
        titleLabel.text = name
        emojiLabel.text = emoji
        cardView.backgroundColor = color
        completeButton.tintColor = color
        daysLabel.text = daysCountText(daysCount)
        let image = isCompletedForSelectedDate ? UIImage(resource: .doneButton) : UIImage(resource: .plusButton)
        completeButton.setImage(image, for: .normal)
        completeButton.alpha = canComplete ? 1 : 0.3
        completeButton.isEnabled = canComplete
    }

    @objc private func completeButtonTapped() {
        onCompleteTapped?()
    }

    // MARK: - Private
    private func daysCountText(_ n: Int) -> String {
        let mod10 = n % 10
        let mod100 = n % 100
        if (11...14).contains(mod100) { return "\(n) дней" }
        switch mod10 {
        case 1: return "\(n) день"
        case 2, 3, 4: return "\(n) дня"
        default: return "\(n) дней"
        }
    }

    private func setup() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackgroundView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)

        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),

            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
