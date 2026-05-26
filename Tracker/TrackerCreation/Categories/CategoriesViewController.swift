import UIKit

final class CategoriesViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: CategoriesViewModel
    var onCategoryPicked: ((TrackerCategory) -> Void)?

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
        label.font = .systemFont(ofSize: Constants.emptyStateLabelFontSize, weight: .medium)
        label.textColor = AppColors.primaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.addCategory, for: .normal)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.backgroundColor = AppColors.primaryLabel
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(viewModel: CategoriesViewModel) {
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
        updateEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.reportOpen(screen: Strings.analyticsScreen)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.reportClose(screen: Strings.analyticsScreen)
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        additionalSafeAreaInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        setupViewHierarchy()
        setupConstraints()
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
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -Constants.tableBottomSpacing),

            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -Constants.emptyStateCenterOffset),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: Constants.emptyStateImageSize),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: Constants.emptyStateImageSize),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Constants.emptyStateLabelTopSpacing),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.labelHorizontalPadding),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.labelHorizontalPadding),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonHorizontalPadding),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonHorizontalPadding),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomPadding),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }


    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
        viewModel.onCategorySelected = { [weak self] category in
            self?.onCategoryPicked?(category)
            self?.navigationController?.popViewController(animated: true)
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
        AnalyticsService.reportClick(screen: Strings.analyticsScreen, item: "add_category")
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] name in
            self?.viewModel.addCategory(name: name)
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }

    private func showDeleteConfirmation(at index: Int) {
        let alert = UIAlertController(title: nil, message: Strings.deleteConfirmation, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        })
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel))
        present(alert, animated: true)
    }

    private func showEditCategory(at index: Int) {
        let currentName = viewModel.categories[index].title
        let editVC = NewCategoryViewController(initialName: currentName)
        editVC.onCategoryCreated = { [weak self] newName in
            self?.viewModel.renameCategory(at: index, newName: newName)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseId, for: indexPath) as? CategoryCell else {
            assertionFailure("Failed to dequeue CategoryCell")
            return UITableViewCell()
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
        AnalyticsService.reportClick(screen: Strings.analyticsScreen, item: "select_category")
        viewModel.selectCategory(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            let edit = UIAction(title: Strings.edit) { [weak self] _ in
                self?.showEditCategory(at: indexPath.row)
            }
            let delete = UIAction(title: Strings.delete, attributes: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation(at: indexPath.row)
            }
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

// MARK: - Constants
private extension CategoriesViewController {
    enum Constants {
        static let emptyStateImageSize: CGFloat = 80
        static let emptyStateCenterOffset: CGFloat = 20
        static let emptyStateLabelTopSpacing: CGFloat = 8
        static let emptyStateLabelFontSize: CGFloat = 12
        static let labelHorizontalPadding: CGFloat = 16
        static let tableBottomSpacing: CGFloat = 16
        static let buttonHorizontalPadding: CGFloat = 20
        static let buttonBottomPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
    }

    enum Strings {
        static let screenTitle = "title_category".localized
        static let addCategory = "button_add_category".localized
        static let emptyState = "empty_state_categories".localized
        static let edit = "context_menu_edit".localized
        static let delete = "button_delete".localized
        static let deleteConfirmation = "alert_delete_category".localized
        static let cancel = "button_cancel".localized
        static let analyticsScreen = "Categories"
    }
}
