import UIKit

final class CategoryCell: UITableViewCell {

    static let reuseId = "CategoryCell"

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = AppColors.secondaryBackground
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentLeading),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.accessoryTrailingReserved),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Configure
    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
        tintColor = AppColors.accentBlue
    }
}

// MARK: - Constants
private extension CategoryCell {
    enum Constants {
        static let contentLeading: CGFloat = 16
        static let accessoryTrailingReserved: CGFloat = 41
    }
}
