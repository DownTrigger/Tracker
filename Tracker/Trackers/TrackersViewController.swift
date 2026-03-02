import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Data
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    private var searchText: String = ""
    private var completedTrackerIdsForSelectedDate: Set<UUID> = []

    private var filteredCategories: [TrackerCategory] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
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
        return result
    }

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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = customDatePicker.date
        rebuildCompletedIdsForSelectedDate()
        setupNavigationBar()
        setupUI()
        setupButtonActions()
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
        setupHierarchy()
        setupConstraints()
        updateEmptyStateVisibility()
    }

    private func setupHierarchy() {
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

    // MARK: - Helpers
    private func updateEmptyStateVisibility() {
        let hasTrackersToShow = filteredCategories.contains { !$0.trackers.isEmpty }
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

    // MARK: - Data mutations
    func completeTracker(id: UUID, date: Date) {
        completedTrackers.append(TrackerRecord(trackerId: id, date: date))
        if Calendar.current.isDate(date, inSameDayAs: currentDate) {
            completedTrackerIdsForSelectedDate.insert(id)
        }
    }

    func uncompleteTracker(id: UUID, date: Date) {
        completedTrackers.removeAll { $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
        if Calendar.current.isDate(date, inSameDayAs: currentDate) {
            completedTrackerIdsForSelectedDate.remove(id)
        }
    }

    func addTracker(_ tracker: Tracker, toCategoryAt index: Int) {
        guard index >= 0, index < categories.count else { return }
        let category = categories[index]
        let newTrackers = category.trackers + [tracker]
        let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
        var newCategories = categories
        newCategories[index] = newCategory
        categories = newCategories
        updateEmptyStateVisibility()
        collectionView.reloadData()
    }

    // MARK: - Actions
    @objc private func addTrackerTapped() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.onCreateTracker = { [weak self] tracker in
            guard let self else { return }
            if self.categories.isEmpty {
                self.categories = [TrackerCategory(title: Strings.defaultCategoryName, trackers: [tracker])]
                self.updateEmptyStateVisibility()
                self.collectionView.reloadData()
            } else {
                self.addTracker(tracker, toCategoryAt: 0)
            }
            self.presentedViewController?.dismiss(animated: true)
        }
        let nav = UINavigationController(rootViewController: typeSelectionVC)
        present(nav, animated: true)
    }

    private func datePickerValueChanged(_ date: Date) {
        currentDate = date
        rebuildCompletedIdsForSelectedDate()
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseId, for: indexPath) as? TrackerCell else {
            fatalError("Failed to dequeue \(TrackerCell.self). Check cell registration.")
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
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
            collectionView.reloadData()
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
        header.configure(title: filteredCategories[indexPath.section].title)
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
