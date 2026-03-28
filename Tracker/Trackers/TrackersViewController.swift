import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Stores
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    // MARK: - Data
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private var searchText: String = ""
    private var completedTrackerIdsForSelectedDate: Set<UUID> = []

    private var displayedCategories: [TrackerCategory] = []

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
        label.text = Strings.emptyStateText
        label.font = UIFont.systemFont(ofSize: Constants.emptyStateFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore, trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = customDatePicker.date
        categories = categoryStore.categories
        completedTrackers = recordStore.records
        rebuildDisplayedCategories()
        rebuildCompletedIdsForSelectedDate()
        setupNavigationBar()
        setupUI()
        setupButtonActions()
        setupStoreObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStoreObservers()
        categories = categoryStore.categories
        completedTrackers = recordStore.records
        rebuildDisplayedCategories()
        rebuildCompletedIdsForSelectedDate()
        collectionView.reloadData()
        updateEmptyStateVisibility()
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
        setupViewHierarchy()
        setupConstraints()
        updateEmptyStateVisibility()
    }

    private func setupViewHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
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
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupButtonActions() {
        customDatePicker.onDateChanged = { [weak self] date in
            self?.datePickerValueChanged(date)
        }
    }

    private func setupStoreObservers() {
        categoryStore.onChange = { [weak self] in
            guard let self else { return }
            self.categories = self.categoryStore.categories
            self.rebuildDisplayedCategories()
            self.rebuildCompletedIdsForSelectedDate()
            self.collectionView.reloadData()
            self.updateEmptyStateVisibility()
        }
        recordStore.onChange = { [weak self] in
            guard let self else { return }
            self.completedTrackers = self.recordStore.records
            self.rebuildCompletedIdsForSelectedDate()
            self.collectionView.reloadData()
        }
    }

    // MARK: - Helpers
    private func rebuildDisplayedCategories() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        var result = categories.map { category in
            TrackerCategory(
                title: category.title,
                trackers: category.trackers.filter { $0.schedule.contains(weekday) }
            )
        }.filter { !$0.trackers.isEmpty }
        if !searchText.isEmpty {
            result = result.map { category in
                TrackerCategory(
                    title: category.title,
                    trackers: category.trackers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                )
            }.filter { !$0.trackers.isEmpty }
        }
        displayedCategories = result
    }

    private func updateEmptyStateVisibility() {
        let hasTrackersToShow = displayedCategories.contains { !$0.trackers.isEmpty }
        emptyStateImageView.isHidden = hasTrackersToShow
        emptyStateLabel.isHidden = hasTrackersToShow
        collectionView.isHidden = !hasTrackersToShow
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }

    private func completedDaysCount(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    private func isCompletedToday(trackerId: UUID) -> Bool {
        completedTrackerIdsForSelectedDate.contains(trackerId)
    }

    private func rebuildCompletedIdsForSelectedDate() {
        let calendar = Calendar.current
        completedTrackerIdsForSelectedDate = Set(
            completedTrackers
                .filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
                .map(\.trackerId)
        )
    }

    // MARK: - Actions
    private func completeTracker(id: UUID, date: Date) {
        recordStore.addRecord(TrackerRecord(trackerId: id, date: date))
    }

    private func uncompleteTracker(id: UUID, date: Date) {
        recordStore.deleteRecord(trackerId: id, date: date)
    }

    private func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        do {
            try trackerStore.addTracker(tracker, toCategoryWithTitle: title)
            categories = categoryStore.categories
            rebuildDisplayedCategories()
            rebuildCompletedIdsForSelectedDate()
            collectionView.reloadData()
            updateEmptyStateVisibility()
        } catch {
            assertionFailure("Failed to add tracker: \(error)")
        }
    }


    @objc private func addTrackerTapped() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.onCreateTracker = { [weak self] tracker, categoryName in
            self?.addTracker(tracker, toCategoryWithTitle: categoryName)
        }
        let nav = UINavigationController(rootViewController: typeSelectionVC)
        present(nav, animated: true)
    }

    private func datePickerValueChanged(_ date: Date) {
        currentDate = date
        rebuildDisplayedCategories()
        rebuildCompletedIdsForSelectedDate()
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        displayedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseId, for: indexPath) as? TrackerCell else {
            fatalError("Failed to dequeue \(TrackerCell.self). Check cell registration.")
        }
        let tracker = displayedCategories[indexPath.section].trackers[indexPath.item]
        let days = completedDaysCount(for: tracker.id)
        let isCompleted = isCompletedToday(trackerId: tracker.id)
        let canComplete = !isFutureDate(currentDate)

        cell.configure(viewModel: .init(
            name: tracker.name,
            emoji: tracker.emoji,
            color: TrackerColors.color(at: tracker.color),
            daysCount: days,
            isCompletedForSelectedDate: isCompleted,
            canComplete: canComplete
        ))

        cell.onCompleteTapped = { [weak self] in
            guard let self else { return }
            let date = self.currentDate
            guard !self.isFutureDate(date) else { return }
            if self.isCompletedToday(trackerId: tracker.id) {
                self.uncompleteTracker(id: tracker.id, date: date)
            } else {
                self.completeTracker(id: tracker.id, date: date)
            }
            collectionView.reloadItems(at: [indexPath])
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
            fatalError("Failed to dequeue \(TrackerSectionHeader.self). Check supplementary view registration.")
        }
        header.configure(title: displayedCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    // TODO: No methods needed yet. 
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        rebuildDisplayedCategories()
        collectionView.reloadData()
        updateEmptyStateVisibility()
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
    }

    enum Strings {
        static let screenTitle = "Трекеры"
        static let searchPlaceholder = "Поиск"
        static let emptyStateText = "Что будем отслеживать?"
        static let defaultCategoryName = "Важное"
    }
}
