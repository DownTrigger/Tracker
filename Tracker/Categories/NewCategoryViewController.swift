import UIKit

final class NewCategoryViewController: UIViewController {

    // MARK: - Callbacks
    var onCategoryCreated: ((String) -> Void)?

    // MARK: - UI
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = Strings.placeholder
        field.font = .systemFont(ofSize: 17)
        field.backgroundColor = AppColors.secondaryBackground
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.done, for: .normal)
        button.setTitleColor(AppColors.accentWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.backgroundColor = AppColors.accentGray
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(textField)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions
    @objc private func textChanged() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText ? AppColors.accentBlack : AppColors.accentGray
    }

    @objc private func doneTapped() {
        guard let name = textField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return }
        onCategoryCreated?(name)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Constants
private extension NewCategoryViewController {
    enum Strings {
        static let screenTitle = "Новая категория"
        static let placeholder = "Введите название категории"
        static let done = "Готово"
    }
}
