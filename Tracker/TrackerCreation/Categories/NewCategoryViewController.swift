import UIKit

final class NewCategoryViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: NewCategoryViewModel

    // MARK: - Callbacks
    var onCategoryCreated: ((String) -> Void)?

    // MARK: - UI
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = Strings.placeholder
        field.font = .systemFont(ofSize: 17)
        field.backgroundColor = AppColors.secondaryBackground
        field.layer.cornerRadius = Constants.textFieldCornerRadius
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.horizontalPadding, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.done, for: .normal)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.isEnabled = false
        button.backgroundColor = AppColors.accentGray
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(viewModel: NewCategoryViewModel = NewCategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
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
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.textFieldTopPadding),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonHorizontalPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonHorizontalPadding),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onFormValidityChanged = { [weak self] isValid in
            self?.doneButton.isEnabled = isValid
            self?.doneButton.backgroundColor = isValid ? AppColors.primaryLabel : AppColors.accentGray
        }
    }

    // MARK: - Actions
    @objc private func textChanged() {
        viewModel.name = textField.text ?? ""
    }

    @objc private func doneTapped() {
        let name = viewModel.trimmedName
        guard !name.isEmpty else { return }
        onCategoryCreated?(name)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Constants
private extension NewCategoryViewController {
    enum Constants {
        static let textFieldTopPadding: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let textFieldHeight: CGFloat = 75
        static let textFieldCornerRadius: CGFloat = 16
        static let buttonHorizontalPadding: CGFloat = 20
        static let buttonBottomPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
    }

    enum Strings {
        static let screenTitle = "Новая категория"
        static let placeholder = "Введите название категории"
        static let done = "Готово"
    }
}
