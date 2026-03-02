import UIKit

final class ColorSectionCell: UITableViewCell {
    static let reuseId = "ColorSectionCell"

    private let colorSelectionView: ColorSelectionView = {
        let view = ColorSelectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(colorSelectionView)
        NSLayoutConstraint.activate([
            colorSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(onColorSelected: ((Int) -> Void)?, selectedColorIndex: Int) {
        colorSelectionView.onColorSelected = onColorSelected
        colorSelectionView.setSelectedIndex(selectedColorIndex)
    }
}
