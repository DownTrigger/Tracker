import UIKit

final class SubtitleCell: UITableViewCell {

    // MARK: - Constants
    static let reuseId = "SubtitleCell"

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = AppColors.primaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Constants.labelsSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewHierarchy()
        setupConstraints()
        backgroundColor = AppColors.secondaryBackground
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Private
    private func setupViewHierarchy() {
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        contentView.addSubview(labelsStack)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentLeading),
            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Constants.contentTrailing)
        ])
    }

    // MARK: - Public
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle.isEmpty ? nil : subtitle
    }
}

// MARK: - Constants
private extension SubtitleCell {
    enum Constants {
        static let contentLeading: CGFloat = 16
        static let contentTrailing: CGFloat = 36
        static let labelsSpacing: CGFloat = 2
    }
}
