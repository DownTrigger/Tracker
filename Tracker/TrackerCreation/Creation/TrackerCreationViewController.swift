import UIKit

class TrackerCreationViewController: UIViewController {

    // MARK: - Callbacks
    var onCreateTracker: ((Tracker, String) -> Void)?

    // MARK: - State
    private var isShowingLimitMessage = false
    internal let viewModel: TrackerCreationViewModel

    // MARK: - Init
    init(viewModel: TrackerCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var trimmedName: String {
        viewModel.trackerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isCreateEnabled: Bool { viewModel.isFormValid }

    var shouldShowNameLimitRow: Bool {
        viewModel.trackerName.count >= TextFieldCell.maxNameLength
    }

    var categoryRowCount: Int { 1 }

    // MARK: - UI
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = AppColors.primaryBackground
        table.sectionHeaderHeight = Constants.tableSectionHeaderHeight
        table.sectionFooterHeight = Constants.tableSectionFooterHeight
        table.delegate = self
        table.dataSource = self
        table.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseId)
        table.register(UITableViewCell.self, forCellReuseIdentifier: TextFieldCell.nameLimitCellReuseId)
        table.register(SubtitleCell.self, forCellReuseIdentifier: SubtitleCell.reuseId)
        table.register(EmojiSectionCell.self, forCellReuseIdentifier: EmojiSectionCell.reuseId)
        table.register(ColorSectionCell.self, forCellReuseIdentifier: ColorSectionCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.cancel, for: .normal)
        button.setTitleColor(AppColors.accentRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.layer.borderWidth = Constants.cancelButtonBorderWidth
        button.layer.borderColor = AppColors.accentRed.cgColor
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.create, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.backgroundColor = AppColors.primaryLabel
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.buttonStackSpacing
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onFormValidityChanged = { [weak self] isValid in
            self?.createButton.isEnabled = isValid
            self?.createButton.backgroundColor = isValid ? AppColors.primaryLabel : AppColors.accentGray
        }
        viewModel.onFormValidityChanged?(viewModel.isFormValid)
    }

    // MARK: - Setup
    private func setupUI() {
        title = screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        additionalSafeAreaInsets = Constants.additionalSafeAreaInsets
        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -Constants.tableViewBottomPadding),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomPadding),
            buttonStack.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    var screenTitle: String { "" }

    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard isCreateEnabled else { return }
        performCreate()
    }

    func performCreate() {}

    func openCategories() {
        let store = CoreDataStack.shared.categoryStore
        let preselected: TrackerCategory? = viewModel.selectedCategoryTitle.flatMap { title in
            store.categories.first { $0.title == title }
        }
        let vm = CategoriesViewModel(store: store, preselected: preselected)
        let categoriesVC = CategoriesViewController(viewModel: vm)
        categoriesVC.onCategoryPicked = { [weak self] category in
            self?.viewModel.selectedCategoryTitle = category.title
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(categoriesVC, animated: true)
    }

    func updateNameLimitRowIfNeeded() {
        guard shouldShowNameLimitRow != isShowingLimitMessage else { return }
        isShowingLimitMessage = shouldShowNameLimitRow
        let indexPath = IndexPath(row: NameRow.nameLimitWarning.rawValue, section: Section.name.rawValue)
        tableView.performBatchUpdates {
            if shouldShowNameLimitRow {
                tableView.insertRows(at: [indexPath], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        let nameCellIndexPath = IndexPath(row: NameRow.textField.rawValue, section: Section.name.rawValue)
        if let nameCell = tableView.cellForRow(at: nameCellIndexPath) {
            nameCell.separatorInset = shouldShowNameLimitRow ? Constants.hiddenSeparatorInset : Constants.defaultSeparatorInset
        }
    }

    // MARK: - Cell Configuration
    func handleNameChange(_ text: String?) {
        viewModel.trackerName = text ?? ""
        updateNameLimitRowIfNeeded()
    }

    func dequeueNameCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseId, for: indexPath) as? TextFieldCell else {
            fatalError("Failed to dequeue \(TextFieldCell.self). Check cell registration.")
        }
        cell.configure(placeholder: Strings.namePlaceholder, currentText: viewModel.trackerName, onText: handleNameChange)
        cell.separatorInset = shouldShowNameLimitRow ? Constants.hiddenSeparatorInset : Constants.defaultSeparatorInset
        return cell
    }

    func dequeueCategoryCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as? SubtitleCell else {
            fatalError("Failed to dequeue \(SubtitleCell.self). Check cell registration.")
        }
        cell.configure(title: Strings.categoryTitle, subtitle: viewModel.selectedCategoryTitle ?? "")
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func dequeueNameLimitCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.nameLimitCellReuseId, for: indexPath)
        cell.textLabel?.text = TextFieldCell.nameLimitFooterText
        cell.textLabel?.font = .systemFont(ofSize: Constants.warningLabelFontSize)
        cell.textLabel?.textColor = AppColors.accentRed
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }

    func dequeueEmojiSectionCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmojiSectionCell.reuseId, for: indexPath) as? EmojiSectionCell else {
            fatalError("Failed to dequeue \(EmojiSectionCell.self). Check cell registration.")
        }
        cell.configure(onEmojiSelected: { [weak self] emoji in
            self?.viewModel.selectedEmoji = emoji
        }, selectedEmoji: viewModel.selectedEmoji)
        return cell
    }

    func dequeueColorSectionCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorSectionCell.reuseId, for: indexPath) as? ColorSectionCell else {
            fatalError("Failed to dequeue \(ColorSectionCell.self). Check cell registration.")
        }
        cell.configure(onColorSelected: { [weak self] index in
            self?.viewModel.selectedColorIndex = index
        }, selectedColorIndex: viewModel.selectedColorIndex)
        return cell
    }

    func cellForCategoryRow(at indexPath: IndexPath) -> UITableViewCell {
        dequeueCategoryCell(in: tableView, at: indexPath)
    }
    
    var emojiToColorSectionSpacing: CGFloat { 0 }
}

// MARK: - Section & Rows
extension TrackerCreationViewController {
    enum Section: Int, CaseIterable {
        case name = 0
        case category = 1
        case emoji = 2
        case color = 3
    }

    enum NameRow: Int, CaseIterable {
        case textField = 0
        case nameLimitWarning = 1
    }
}

// MARK: - Constants
private extension TrackerCreationViewController {
    enum Constants {
        // MARK: - Table
        static let tableSectionHeaderHeight: CGFloat = 12
        static let tableSectionFooterHeight: CGFloat = 12
        static let categorySectionFooterHeight: CGFloat = 38

        // MARK: - Buttons
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let buttonStackSpacing: CGFloat = 8
        static let cancelButtonBorderWidth: CGFloat = 1
        static let horizontalPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 16
        
        static let tableViewBottomPadding: CGFloat = 16

        // MARK: - View
        static let additionalSafeAreaInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)

        // MARK: - Rows & cells
        static let standardRowHeight: CGFloat = 75
        static let nameLimitRowHeight: CGFloat = 38
        static let cellCornerRadius: CGFloat = 10
        static let warningLabelFontSize: CGFloat = 17
        static let hiddenSeparatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        static let defaultSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

        // MARK: - Section headers
        static let sectionHeaderLeading: CGFloat = 12
        static let sectionHeaderFontSize: CGFloat = 19

        // MARK: - Emoji & color sections
        static let emojiSectionVerticalInsetTotal: CGFloat = 48
        static let colorSectionVerticalInsetTotal: CGFloat = 48

    }

    enum Strings {
        // MARK: - Buttons
        static let cancel = "Отменить"
        static let create = "Создать"

        // MARK: - Labels & placeholders
        static let namePlaceholder = "Введите название трекера"
        static let categoryTitle = "Категория"
        static let emojiSectionTitle = "Emoji"
        static let colorSectionTitle = "Цвет"
    }
}

// MARK: - UITableViewDataSource
extension TrackerCreationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionKind = Section(rawValue: section) else { return 0 }
        switch sectionKind {
        case .name:
            return shouldShowNameLimitRow ? NameRow.allCases.count : 1
        case .category:
            return categoryRowCount
        case .emoji, .color:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected section: \(indexPath.section)")
        }
        switch section {
        case .name:
            guard let row = NameRow(rawValue: indexPath.row) else {
                fatalError("Unexpected row in name section: \(indexPath.row)")
            }
            switch row {
            case .textField:
                return dequeueNameCell(in: tableView, at: indexPath)
            case .nameLimitWarning:
                return dequeueNameLimitCell(in: tableView, at: indexPath)
            }
        case .category:
            return cellForCategoryRow(at: indexPath)
        case .emoji:
            return dequeueEmojiSectionCell(in: tableView, at: indexPath)
        case .color:
            return dequeueColorSectionCell(in: tableView, at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue: indexPath.section) == .name,
           NameRow(rawValue: indexPath.row) == .nameLimitWarning {
            return Constants.nameLimitRowHeight
        }
        if Section(rawValue: indexPath.section) == .emoji {
            let width = tableView.bounds.width
            return EmojiSelectionView.preferredContentHeight(forWidth: width) + Constants.emojiSectionVerticalInsetTotal
        }
        if Section(rawValue: indexPath.section) == .color {
            let width = tableView.bounds.width
            return ColorSelectionView.preferredContentHeight(forWidth: width) + Constants.colorSectionVerticalInsetTotal
        }
        return Constants.standardRowHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionKind = Section(rawValue: section) else { return nil }
        let title: String?
        switch sectionKind {
        case .emoji: title = Strings.emojiSectionTitle
        case .color: title = Strings.colorSectionTitle
        default: return nil
        }
        guard let text = title else { return nil }
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: Constants.sectionHeaderFontSize, weight: .bold)
        label.textColor = AppColors.primaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Constants.sectionHeaderLeading),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let sectionKind = Section(rawValue: section) else { return Constants.tableSectionFooterHeight }
        switch sectionKind {
        case .category: return Constants.categorySectionFooterHeight
        case .emoji: return emojiToColorSectionSpacing
        default: return Constants.tableSectionFooterHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionKind = Section(rawValue: section) else { return 0 }
        switch sectionKind {
        case .emoji, .color: return 0
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if Section(rawValue: indexPath.section) == .emoji || Section(rawValue: indexPath.section) == .color {
            cell.contentView.backgroundColor = .clear
            cell.contentView.layer.cornerRadius = Constants.cellCornerRadius
            cell.contentView.layer.masksToBounds = true
            return
        }
        guard Section(rawValue: indexPath.section) == .name else { return }
        cell.backgroundColor = .clear
        let rowCount = tableView.numberOfRows(inSection: indexPath.section)
        if NameRow(rawValue: indexPath.row) == .textField {
            applyNameCellStyle(cell, rowCount: rowCount)
        } else {
            applyWarningCellStyle(cell)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Section(rawValue: indexPath.section) == .category && indexPath.row == 0 {
            openCategories()
        }
    }

    private func applyNameCellStyle(_ cell: UITableViewCell, rowCount: Int) {
        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.contentView.layer.cornerRadius = Constants.cellCornerRadius
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner,
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner
        ]
        cell.separatorInset = rowCount > 1 ? Constants.hiddenSeparatorInset : Constants.defaultSeparatorInset
    }

    private func applyWarningCellStyle(_ cell: UITableViewCell) {
        cell.contentView.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.masksToBounds = false
        cell.separatorInset = Constants.hiddenSeparatorInset
    }
}
