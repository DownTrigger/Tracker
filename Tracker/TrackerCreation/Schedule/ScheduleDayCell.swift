import UIKit

final class ScheduleDayCell: UITableViewCell {

    // MARK: - Constants
    static let reuseId = "ScheduleDayCell"

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = AppColors.primaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let switchControl: UISwitch = {
        let control = UISwitch()
        control.onTintColor = AppColors.accentBlue
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private var onSwitchChanged: ((Bool) -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewHierarchy()
        setupConstraints()
        backgroundColor = AppColors.secondaryBackground
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: Constants.horizontalPadding, bottom: 0, right: Constants.horizontalPadding)
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Private
    private func setupViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Public
    func configure(title: String, isOn: Bool, onSwitchChanged: @escaping (Bool) -> Void) {
        titleLabel.text = title
        switchControl.isOn = isOn
        self.onSwitchChanged = onSwitchChanged
    }

    // MARK: - Actions
    @objc private func switchChanged() {
        onSwitchChanged?(switchControl.isOn)
    }
}

// MARK: - Constants
private extension ScheduleDayCell {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
    }
}
