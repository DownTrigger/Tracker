import UIKit

final class CategoriesViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: CategoriesViewModel

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = AppColors.primaryBackground
        table.separatorStyle = .singleLine
        table.rowHeight = 75
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseId)
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .emptyState)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.emptyState
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.primaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.addCategory, for: .normal)
        button.setTitleColor(AppColors.accentWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = AppColors.accentBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        updateEmptyState()
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        setupViewHierarchy()
        setupConstraints()
        setupLongPress()
    }

    private func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(addButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupLongPress() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(gesture)
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
    }

    // MARK: - Helpers
    private func updateEmptyState() {
        let isEmpty = viewModel.categories.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    // MARK: - Actions
    @objc private func addCategoryTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] name in
            self?.viewModel.addCategory(name: name)
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
        })
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseId, for: indexPath) as? CategoryCell else {
            fatalError("Failed to dequeue CategoryCell")
        }
        let category = viewModel.categories[indexPath.row]
        let isSelected = viewModel.selectedCategory?.title == category.title
        cell.configure(title: category.title, isSelected: isSelected)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}

// MARK: - Constants
private extension CategoriesViewController {
    enum Strings {
        static let screenTitle = "Категория"
        static let addCategory = "Добавить категорию"
        static let emptyState = "Привычки и события можно\nобъеденить по смыслу"
        static let delete = "Удалить"
        static let cancel = "Отменить"
    }
}
