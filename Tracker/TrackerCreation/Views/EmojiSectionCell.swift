import UIKit

final class EmojiSectionCell: UITableViewCell {

    // MARK: - Constants
    static let reuseId = Constants.reuseId

    // MARK: - UI
    private let emojiSelectionView: EmojiSelectionView = {
        let view = EmojiSelectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupViewHierarchy()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods
    func configure(onEmojiSelected: ((String) -> Void)?, selectedEmoji: String) {
        emojiSelectionView.onEmojiSelected = onEmojiSelected
        emojiSelectionView.setSelectedValue(selectedEmoji)
    }

    // MARK: - Setup
    private func setupViewHierarchy() {
        contentView.addSubview(emojiSelectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

private extension EmojiSectionCell {
    enum Constants {
        static let reuseId = "EmojiSectionCell"
    }
}
