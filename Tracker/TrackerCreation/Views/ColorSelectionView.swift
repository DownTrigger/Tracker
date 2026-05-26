import UIKit

final class ColorSelectionView: UIView {

    // MARK: - Callbacks
    var onColorSelected: ((Int) -> Void)?

    // MARK: - State
    private var selectedColorIndex: Int = -1

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
        cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public
    func setSelectedIndex(_ index: Int) {
        selectedColorIndex = index
        collectionView.reloadData()
    }

    static func preferredContentHeight(forWidth width: CGFloat) -> CGFloat {
        guard width > 0 else { return 3 * Constants.cellSizeMax + 2 * Constants.spacing }
        let columnCount = Constants.columnCount
        let spacing = Constants.spacing
        let cellSizeMax = Constants.cellSizeMax
        let totalSpacing = spacing * CGFloat(columnCount - 1)
        let cellSize = min(max((width - totalSpacing) / CGFloat(columnCount), 0), cellSizeMax)
        let rowCount = (TrackerColors.palette.count + columnCount - 1) / columnCount
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
extension ColorSelectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        TrackerColors.palette.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as? ColorCell else {
            assertionFailure("Failed to dequeue ColorCell")
            return UICollectionViewCell()
        }
        let color = TrackerColors.palette[indexPath.item]
        let isSelected = indexPath.item == selectedColorIndex
        cell.configure(color: color, isSelected: isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ColorSelectionView: UICollectionViewDelegateFlowLayout {
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
        selectedColorIndex = indexPath.item
        collectionView.reloadData()
        onColorSelected?(indexPath.item)
    }
}

// MARK: - ColorCell
private final class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"

    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let selectionBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = Constants.colorCornerRadius
        colorView.layer.masksToBounds = true
        selectionBorderView.layer.cornerRadius = Constants.selectionCornerRadius
    }

    func configure(color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        selectionBorderView.layer.borderWidth = isSelected ? Constants.borderWidth : 0
        selectionBorderView.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : nil
    }

    private func setupViewHierarchy() {
        contentView.addSubview(selectionBorderView)
        contentView.addSubview(colorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            selectionBorderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBorderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBorderView.widthAnchor.constraint(equalToConstant: Constants.selectionFrameSize),
            selectionBorderView.heightAnchor.constraint(equalToConstant: Constants.selectionFrameSize),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: Constants.colorViewSize),
            colorView.heightAnchor.constraint(equalToConstant: Constants.colorViewSize)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    // MARK: - Grid
    static let cellSizeMax: CGFloat = 52
    static let selectionFrameSize: CGFloat = 52
    static let colorViewSize: CGFloat = 40
    static let spacing: CGFloat = 5
    static let columnCount = 6

    // MARK: - Appearance
    static let colorCornerRadius: CGFloat = 8
    static let selectionCornerRadius: CGFloat = 12.5
    static let borderWidth: CGFloat = 3

    // MARK: - Insets
    static let sectionInsets = UIEdgeInsets(top: 24, left: 2, bottom: 24, right: 2)
}
