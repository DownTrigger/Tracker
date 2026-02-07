import UIKit

final class TrackersViewController: UIViewController {
    
    let addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .addButton), for: .normal)
        button.tintColor = UIColor(resource: .addButton)
        return button
    }()
    
    let dateButton: UIButton = {
        let button = UIButton(type: .system)
        let title = Date.trackerDateString()

        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.label
            ])
        )
        config.background.backgroundColor = .systemGray5
        config.background.cornerRadius = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 5.5, bottom: 6, trailing: 5.5)
        button.configuration = config

        return button
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
    
    // MARK: - Action
    @objc private func addTrackerTapped() {
        
    }
    
    @objc private func dateTapped() {
        
    }
    
    @objc private func dateTouchDown() {
        dateButton.alpha = 0.6
    }
    
    @objc private func dateTouchEnd() {
        dateButton.alpha = 1
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(addTrackerButton)
        view.addSubview(dateButton)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateButton.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            
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
        dateButton.addTarget(self, action: #selector(dateTapped), for: .touchUpInside)
        
        dateButton.addTarget(self, action: #selector(dateTouchDown), for: .touchDown)
        dateButton.addTarget(self, action: #selector(dateTouchEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
