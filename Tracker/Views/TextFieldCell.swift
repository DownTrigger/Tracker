import UIKit

final class TextFieldCell: UITableViewCell {

    // MARK: - Constants
    static let reuseId = "TextFieldCell"
    static let maxNameLength = 38
    static let nameLimitFooterText = "Ограничение 38 символов"
    static let nameLimitCellReuseId = "NameLimitCell"

    // MARK: - UI
    private let textField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 17)
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done 
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    // MARK: - Callbacks
    private var onText: ((String?) -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupConstraints()
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        backgroundColor = AppColors.secondaryBackground
        selectionStyle = .none
    }

    // MARK: - Setup
    private func setupHierarchy() {
        contentView.addSubview(textField)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Public
    func configure(placeholder: String, currentText: String, onText: @escaping (String?) -> Void) {
        textField.placeholder = placeholder
        textField.text = currentText
        self.onText = onText
    }

    // MARK: - Actions
    @objc private func editingChanged() {
        onText?(textField.text)
    }

    // MARK: - Static
    static func makeNameLimitFooter() -> UIView {
        let label = UILabel()
        label.text = nameLimitFooterText
        label.font = .systemFont(ofSize: 17)
        label.textColor = AppColors.accentRed
        label.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8)
        ])
        return container
    }
}

// MARK: - UITextFieldDelegate
extension TextFieldCell: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let rangeInSwift = Range(range, in: currentText) else { return true }
        let newText = currentText.replacingCharacters(in: rangeInSwift, with: string)
        return newText.count <= Self.maxNameLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
