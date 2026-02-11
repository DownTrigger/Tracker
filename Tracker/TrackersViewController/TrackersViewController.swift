import UIKit

final class TrackersViewController: UIViewController {

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

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
    }

    // MARK: - Action
    @objc private func addTrackerTapped() {

    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let formattedDate = Date.trackerDateString(from: sender.date)
        print("Выбранная дата: \(formattedDate)")
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(addTrackerButton)
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
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
            
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupButtonActions() {
        addTrackerButton.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
