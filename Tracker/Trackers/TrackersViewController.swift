import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: TrackersViewModel
    private let categoryStore: TrackerCategoryStore

    // MARK: - UI
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = Strings.searchPlaceholder
        controller.searchBar.backgroundImage = UIImage()
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: TrackersCollectionLayout.create())
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .automatic
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseId)
        view.register(
            TrackerSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeader.reuseId
        )
        view.dataSource = self
        view.delegate = self
        return view
    }()

    private let customDatePicker: CustomDatePickerView = {
        let view = CustomDatePickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emptyStateImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .emptyState)
        return image
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.emptyStateFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.filtersButton, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Constants.filterButtonFontSize)
        button.backgroundColor = AppColors.accentBlue
        button.layer.cornerRadius = Constants.filterButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(viewModel: TrackersViewModel, categoryStore: TrackerCategoryStore) {
        self.viewModel = viewModel
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupButtonActions()
        bindViewModel()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = Strings.screenTitle
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(resource: .addButton), for: .normal)
        addButton.tintColor = AppColors.primaryLabel
        addButton.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)

        let addButtonContainer = UIView()
        addButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        addButtonContainer.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButtonContainer.widthAnchor.constraint(equalToConstant: Constants.addButtonContainerWidth),
            addButtonContainer.heightAnchor.constraint(equalToConstant: Constants.addButtonContainerHeight),
            addButton.leadingAnchor.constraint(equalTo: addButtonContainer.leadingAnchor, constant: Constants.addButtonLeadingOffset),
            addButton.centerYAnchor.constraint(equalTo: addButtonContainer.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: Constants.addButtonSize),
            addButton.heightAnchor.constraint(equalToConstant: Constants.addButtonSize)
        ])

        let addItem = UIBarButtonItem(customView: addButtonContainer)
        navigationItem.leftBarButtonItem = addItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customDatePicker)
    }

    private func setupUI() {
        view.backgroundColor = AppColors.primaryBackground
        setupViewHierarchy()
        setupConstraints()
        collectionView.contentInset.bottom = Constants.filterButtonHeight + Constants.filterButtonBottomSpacing * 2
        updateEmptyStateVisibility()
    }

    private func setupViewHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(filtersButton)
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: Constants.emptyStateImageSize),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: Constants.emptyStateImageSize),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Constants.emptyStateSpacing),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.filterButtonBottomSpacing),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.widthAnchor.constraint(equalToConstant: Constants.filterButtonWidth),
            filtersButton.heightAnchor.constraint(equalToConstant: Constants.filterButtonHeight)
        ])
    }

    private func setupButtonActions() {
        customDatePicker.onDateChanged = { [weak self] date in
            self?.viewModel.setDate(date)
        }
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateEmptyStateVisibility()
        }
    }

    // MARK: - Helpers
    private func updateEmptyStateVisibility() {
        let hasDisplayed = viewModel.displayedCategories.contains { !$0.trackers.isEmpty }
        let hasForDate = viewModel.hasTrackersForCurrentDate

        if hasDisplayed {
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
            collectionView.isHidden = false
        } else if hasForDate {
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = Strings.nothingFoundText
            collectionView.isHidden = true
        } else {
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = Strings.emptyStateText
            collectionView.isHidden = true
        }

        filtersButton.isHidden = !hasForDate
    }

    // MARK: - Actions
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let tracker = viewModel.displayedCategories[indexPath.section].trackers[indexPath.item]
        let alert = UIAlertController(title: nil, message: Strings.deleteConfirmation, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(id: tracker.id)
        })
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel))
        present(alert, animated: true)
    }

    private func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        viewModel.addTracker(tracker, categoryName: title)
    }

    @objc private func addTrackerTapped() {
        let typeSelectionVC = TrackerTypeSelectionViewController(categoryStore: categoryStore)
        typeSelectionVC.onCreateTracker = { [weak self] tracker, categoryName in
            self?.addTracker(tracker, toCategoryWithTitle: categoryName)
        }
        let nav = UINavigationController(rootViewController: typeSelectionVC)
        present(nav, animated: true)
    }

    @objc private func filtersButtonTapped() {
        let filtersVM = FiltersViewModel(activeFilter: viewModel.activeFilter)
        let filtersVC = FiltersViewController(viewModel: filtersVM)
        filtersVC.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            self.viewModel.setFilter(filter)
            if filter == .today {
                self.customDatePicker.date = Date()
            }
        }
        let nav = UINavigationController(rootViewController: filtersVC)
        present(nav, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.displayedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.displayedCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseId, for: indexPath) as? TrackerCell else {
            assertionFailure("Failed to dequeue \(TrackerCell.self). Check cell registration.")
            return UICollectionViewCell()
        }
        let tracker = viewModel.displayedCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = viewModel.isCompletedToday(trackerId: tracker.id)
        let canComplete = viewModel.canComplete(for: viewModel.currentDate)

        cell.configure(viewModel: .init(
            name: tracker.name,
            emoji: tracker.emoji,
            color: TrackerColors.color(at: tracker.color),
            daysText: viewModel.daysCountText(for: tracker.id),
            isCompletedForSelectedDate: isCompleted,
            canComplete: canComplete,
            isPinned: tracker.isPinned
        ))

        cell.onCompleteTapped = { [weak self] in
            guard let self, self.viewModel.canComplete(for: self.viewModel.currentDate) else { return }
            self.viewModel.toggleCompletion(trackerId: tracker.id)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeader.reuseId,
            for: indexPath
        ) as? TrackerSectionHeader else {
            assertionFailure("Failed to dequeue \(TrackerSectionHeader.self). Check supplementary view registration.")
            return UICollectionReusableView()
        }
        header.configure(title: viewModel.displayedCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = viewModel.displayedCategories[indexPath.section].trackers[indexPath.item]
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            let pinTitle = tracker.isPinned ? Strings.unpin : Strings.pin
            let pin = UIAction(title: pinTitle) { [weak self] _ in
                if tracker.isPinned {
                    self?.viewModel.unpinTracker(id: tracker.id)
                } else {
                    self?.viewModel.pinTracker(id: tracker.id)
                }
            }
            let edit = UIAction(title: Strings.edit) { _ in }
            let delete = UIAction(title: Strings.delete, attributes: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation(for: indexPath)
            }
            return UIMenu(title: "", children: [pin, edit, delete])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration, in: collectionView)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration, in: collectionView)
    }

    private func makeTargetedPreview(
        for configuration: UIContextMenuConfiguration,
        in collectionView: UICollectionView
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? NSIndexPath,
              let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? TrackerCell
        else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell.previewView, parameters: parameters)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.setSearchText(text)
    }
}

// MARK: - Constants
private extension TrackersViewController {
    enum Constants {
        // MARK: - Empty state
        static let emptyStateFontSize: CGFloat = 12
        static let emptyStateImageSize: CGFloat = 80
        static let emptyStateSpacing: CGFloat = 8

        // MARK: - Layout
        static let horizontalPadding: CGFloat = 16

        // MARK: - Add button
        static let addButtonContainerWidth: CGFloat = 52
        static let addButtonContainerHeight: CGFloat = 44
        static let addButtonSize: CGFloat = 44
        static let addButtonLeadingOffset: CGFloat = -12

        // MARK: - Filters button
        static let filterButtonWidth: CGFloat = 114
        static let filterButtonHeight: CGFloat = 50
        static let filterButtonBottomSpacing: CGFloat = 16
        static let filterButtonCornerRadius: CGFloat = 16
        static let filterButtonFontSize: CGFloat = 17
    }

    enum Strings {
        static let screenTitle = "title_trackers".localized
        static let searchPlaceholder = "search_placeholder_trackers".localized
        static let emptyStateText = "empty_state_trackers".localized
        static let nothingFoundText = "empty_state_nothing_found".localized
        static let filtersButton = "button_filters".localized
        static let pin = "context_menu_pin".localized
        static let unpin = "context_menu_unpin".localized
        static let edit = "context_menu_edit".localized
        static let delete = "context_menu_delete".localized
        static let deleteConfirmation = "alert_delete_tracker".localized
        static let cancel = "button_cancel".localized
    }
}
