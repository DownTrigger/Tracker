import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Data
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    private var searchText: String = ""

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
        controller.searchBar.placeholder = "Поиск"
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
    
    let emptyStateImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .emptyState)
        return image
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = customDatePicker.date
        setupNavigationBar()
        setupUI()
        setupButtonActions()
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
        return completedTrackers.contains { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
    }
    
    // MARK: - Data
    func completeTracker(id: UUID, date: Date) {
        completedTrackers.append(TrackerRecord(trackerId: id, date: date))
    }

    func uncompleteTracker(id: UUID, date: Date) {
        completedTrackers.removeAll { $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
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

    // MARK: - Action
    @objc private func addTrackerTapped() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.onCreateTracker = { [weak self] tracker in
            guard let self else { return }
            if self.categories.isEmpty {
                self.categories = [TrackerCategory(title: "Важное", trackers: [tracker])]
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
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)

        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        updateEmptyStateVisibility()
    }

    private func setupButtonActions() {
        customDatePicker.onDateChanged = { [weak self] date in
            self?.datePickerValueChanged(date)
        }
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Трекеры"
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
            addButtonContainer.widthAnchor.constraint(equalToConstant: 52),
            addButtonContainer.heightAnchor.constraint(equalToConstant: 44),
            addButton.leadingAnchor.constraint(equalTo: addButtonContainer.leadingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: addButtonContainer.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        let addItem = UIBarButtonItem(customView: addButtonContainer)
        navigationItem.leftBarButtonItem = addItem

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customDatePicker)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseId, for: indexPath) as! TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let days = completedDaysCount(for: tracker.id)
        let isCompleted = isCompletedToday(trackerId: tracker.id)
        let canComplete = !isFutureDate(currentDate)
        
        cell.setup(viewModel: .init(
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
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeader.reuseId,
            for: indexPath
        ) as! TrackerSectionHeader
        header.configure(title: filteredCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
}
