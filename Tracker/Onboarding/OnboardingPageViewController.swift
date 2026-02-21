import UIKit

final class OnboardingPageViewController: UIViewController {

    // MARK: - Model
    struct PageContent {
        let title: String
        let image: UIImage
    }

    let pageIndex: Int

    // MARK: - UI
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.textColor = AppColors.accentBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    init(content: PageContent, pageIndex: Int) {
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = content.title
        backgroundImageView.image = content.image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Constants.titleCenterYOffset)
        ])
    }
}

// MARK: - Constants
private extension OnboardingPageViewController {
    enum Constants {
        static let titleFontSize: CGFloat = 32
        static let titleHorizontalPadding: CGFloat = 16
        static let titleCenterYOffset: CGFloat = 64
    }
}
