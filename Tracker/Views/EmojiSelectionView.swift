import UIKit

final class EmojiSelectionView: UIView {

    // MARK: - Callbacks
    var onEmojiSelected: ((String) -> Void)?

    // MARK: - State
    private var selectedEmoji: String = ""

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.spacing
        layout.minimumLineSpacing = Constants.spacing
        layout.sectionInset = Constants.sectionInsets
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.showsVerticalScrollIndicator = false
        cv.clipsToBounds = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViewHierarchy()
        setupConstraints()
    }

    // MARK: - Public
    func setSelectedValue(_ emoji: String) {
        selectedEmoji = emoji
        collectionView.reloadData()
    }

    var selectedValue: String {
        selectedEmoji
    }

    static func preferredContentHeight(forWidth width: CGFloat) -> CGFloat {
        guard width > 0 else { return 4 * Constants.cellSizeMax + 3 * Constants.spacing }
        let columnCount = Constants.columnCount
        let spacing = Constants.spacing
        let cellSizeMax = Constants.cellSizeMax
        let totalSpacing = spacing * CGFloat(columnCount - 1)
        let cellSize = min(max((width - totalSpacing) / CGFloat(columnCount), 0), cellSizeMax)
        let rowCount = (TrackerEmojis.all.count + columnCount - 1) / columnCount
        return CGFloat(rowCount) * cellSize + CGFloat(max(0, rowCount - 1)) * spacing
    }

    // MARK: - Private
    private func setupViewHierarchy() {
        addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension EmojiSelectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        TrackerEmojis.all.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as? EmojiCell else {
            fatalError("Failed to dequeue EmojiCell")
        }
        let emoji = TrackerEmojis.all[indexPath.item]
        cell.configure(emoji: emoji, isSelected: emoji == selectedEmoji)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EmojiSelectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        var totalWidth = collectionView.bounds.width - (layout?.sectionInset.left ?? 0) - (layout?.sectionInset.right ?? 0)
        if totalWidth <= 0 { totalWidth = collectionView.bounds.width }
        if totalWidth <= 0 { return CGSize(width: Constants.cellSizeMax, height: Constants.cellSizeMax) }
        let spacing = layout?.minimumInteritemSpacing ?? Constants.spacing
        let totalSpacing = spacing * CGFloat(Constants.columnCount - 1)
        let width = (totalWidth - totalSpacing) / CGFloat(Constants.columnCount)
        let size = min(max(width, 0), Constants.cellSizeMax)
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = TrackerEmojis.all[indexPath.item]
        selectedEmoji = emoji
        collectionView.reloadData()
        onEmojiSelected?(emoji)
    }
}

// MARK: - EmojiCell
private final class EmojiCell: UICollectionViewCell {
    static let reuseId = "EmojiCell"

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = Constants.selectionRadius
        contentView.layer.masksToBounds = true
    }

    func configure(emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? AppColors.accentLightGray : .clear
    }

    private func setupViewHierarchy() {
        contentView.addSubview(emojiLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    // MARK: - Grid
    static let cellSizeMax: CGFloat = 52
    static let spacing: CGFloat = 5
    static let columnCount = 6
    static let selectionRadius: CGFloat = 16

    // MARK: - Insets
    static let sectionInsets = UIEdgeInsets(top: 24, left: 2, bottom: 24, right: 2)
}
