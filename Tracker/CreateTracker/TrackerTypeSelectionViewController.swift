import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    var onCreateTracker: ((Tracker) -> Void)?

    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.backgroundColor = AppColors.primaryLabel
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.backgroundColor = AppColors.primaryLabel
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Создание трекера"
        view.backgroundColor = AppColors.primaryBackground
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventButton)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func habitTapped() {
        let vc = NewHabitViewController()
        vc.onCreateTracker = { [weak self] tracker in
            self?.onCreateTracker?(tracker)
            self?.navigationController?.dismiss(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func irregularEventTapped() {
        let vc = NewIrregularEventViewController()
        vc.onCreateTracker = { [weak self] tracker in
            self?.onCreateTracker?(tracker)
            self?.navigationController?.dismiss(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
