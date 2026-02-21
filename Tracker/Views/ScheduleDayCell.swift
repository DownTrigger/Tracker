import UIKit

final class ScheduleDayCell: UITableViewCell {

    static let reuseId = "ScheduleDayCell"

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        backgroundColor = AppColors.secondaryBackground
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, isOn: Bool, onSwitchChanged: @escaping (Bool) -> Void) {
        titleLabel.text = title
        switchControl.isOn = isOn
        self.onSwitchChanged = onSwitchChanged
    }

    @objc private func switchChanged() {
        onSwitchChanged?(switchControl.isOn)
    }
}
