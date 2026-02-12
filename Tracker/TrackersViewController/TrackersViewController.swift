import UIKit

final class TrackersViewController: UIViewController {

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var searchText: String = ""

    private var filteredCategories: [TrackerCategory] {
        let calendar = Calendar.current
        let selected = datePicker.date
        let weekday = calendar.component(.weekday, from: selected)
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

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: TrackersCollectionLayout.create())
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseId)
        cv.register(
            TrackerSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeader.reuseId
        )
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .addButton), for: .normal)
        button.tintColor = UIColor(resource: .addButton)
        return button
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = .current
        picker.calendar = .current
        return picker
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск"
        search.backgroundImage = UIImage()
        return search
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
        setupNavigationBar()
        setupViews()
        setupButtonActions()
        loadSampleData()
    }

    private func loadSampleData() {
        let water = Tracker(
            id: UUID(),
            name: "Поливать растения",
            color: 3,
            emoji: "❤️",
            schedule: [1, 2, 3, 4, 5, 6, 7]
        )
        let cat = Tracker(
            id: UUID(),
            name: "Кошка заслонила камеру на созвоне",
            color: 1,
            emoji: "😻",
            schedule: [1, 2, 3, 4, 5, 6, 7]
        )
        let grandma = Tracker(
            id: UUID(),
            name: "Бабушка прислала открытку в вотсапе",
            color: 0,
            emoji: "🤯",
            schedule: [1, 2, 3, 4, 5, 6, 7]
        )
        let dates = Tracker(
            id: UUID(),
            name: "Свидания в апреле",
            color: 6,
            emoji: "❤️",
            schedule: [1, 2, 3, 4, 5, 6, 7]
        )
        categories = [
            TrackerCategory(title: "Домашний уют", trackers: [water]),
            TrackerCategory(title: "Радостные мелочи", trackers: [cat, grandma, dates])
        ]
        let calendar = Calendar.current
        let today = Date()
        completedTrackers = [TrackerRecord(trackerId: water.id, date: today)]
        for i in 1..<5 { completedTrackers.append(TrackerRecord(trackerId: cat.id, date: calendar.date(byAdding: .day, value: -i, to: today)!)) }
        for i in 1..<4 { completedTrackers.append(TrackerRecord(trackerId: grandma.id, date: calendar.date(byAdding: .day, value: -i, to: today)!)) }
        for i in 1..<5 { completedTrackers.append(TrackerRecord(trackerId: dates.id, date: calendar.date(byAdding: .day, value: -i, to: today)!)) }
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }

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
        let selected = datePicker.date
        return completedTrackers.contains { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: selected)
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

    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(addTrackerButton)
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
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
        addTrackerButton.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        searchBar.delegate = self
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        let selectedDate = datePicker.date
        let days = completedDaysCount(for: tracker.id)
        let isCompleted = isCompletedToday(trackerId: tracker.id)
        let canComplete = !isFutureDate(selectedDate)

        cell.configure(
            name: tracker.name,
            emoji: tracker.emoji,
            color: TrackerColors.color(at: tracker.color),
            daysCount: days,
            isCompletedForSelectedDate: isCompleted,
            canComplete: canComplete
        )

        cell.onCompleteTapped = { [weak self] in
            guard let self else { return }
            let date = self.datePicker.date
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

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
