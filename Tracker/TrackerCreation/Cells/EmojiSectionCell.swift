import UIKit

final class EmojiSectionCell: UITableViewCell {
    static let reuseId = "EmojiSectionCell"

    private let emojiSelectionView: EmojiSelectionView = {
        let view = EmojiSelectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(emojiSelectionView)
        NSLayoutConstraint.activate([
            emojiSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(onEmojiSelected: ((String) -> Void)?, selectedEmoji: String) {
        emojiSelectionView.onEmojiSelected = onEmojiSelected
        emojiSelectionView.setSelectedValue(selectedEmoji)
    }
}
