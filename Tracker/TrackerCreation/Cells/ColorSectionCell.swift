import UIKit

final class ColorSectionCell: UITableViewCell {

    // MARK: - Constants
    static let reuseId = Constants.reuseId

    // MARK: - UI
    private let colorSelectionView: ColorSelectionView = {
        let view = ColorSelectionView()
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configure(onColorSelected: ((Int) -> Void)?, selectedColorIndex: Int) {
        colorSelectionView.onColorSelected = onColorSelected
        colorSelectionView.setSelectedIndex(selectedColorIndex)
    }

    // MARK: - Setup
    private func setupViewHierarchy() {
        contentView.addSubview(colorSelectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

private extension ColorSectionCell {
    enum Constants {
        static let reuseId = "ColorSectionCell"
    }
}
