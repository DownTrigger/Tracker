import UIKit

final class OnboardingViewController: UIViewController {

    // MARK: - Data
    private static let pages: [PageContent] = [
        .init(
            title: Strings.page1Title,
            image: UIImage(resource: .blueBackground)
        ),
        .init(
            title: Strings.page2Title,
            image: UIImage(resource: .redBackground)
        )
    ]

    private var currentPageIndex: Int = 0

    // MARK: - UI
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        vc.dataSource = self
        vc.delegate = self
        vc.setViewControllers(
            [makePageViewController(at: 0)],
            direction: .forward,
            animated: false
        )
        return vc
    }()

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = Constants.pagesCount
        control.currentPage = 0
        control.currentPageIndicatorTintColor = AppColors.accentBlack
        control.pageIndicatorTintColor = AppColors.accentBlack.withAlphaComponent(Constants.pageControlInactiveAlpha)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.primaryButtonTitle, for: .normal)
        button.setTitleColor(AppColors.accentWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.backgroundColor = AppColors.accentBlack
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.primaryBackground
        addChild(pageViewController)
        setupViewHierarchy()
        setupConstraints()
        pageViewController.didMove(toParent: self)
    }

    private func setupViewHierarchy() {
        view.addSubview(pageViewController.view)
        view.addSubview(pageControl)
        view.addSubview(primaryButton)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageControl.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -Constants.pageControlSpacing),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomPadding),
            primaryButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Helpers
    private func makePageViewController(at index: Int) -> OnboardingPageViewController {
        let content = Self.pages[index]
        return OnboardingPageViewController(content: content, pageIndex: index)
    }

    private func showMainApp() {
        UserDefaults.standard.set(true, forKey: Constants.onboardingCompletedKey)
        guard let window = view.window else { return }
        window.rootViewController = TabBarViewController()
    }

    // MARK: - Actions
    @objc private func primaryButtonTapped() {
        showMainApp()
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let pageVC = viewController as? OnboardingPageViewController else { return nil }
        let index = pageVC.pageIndex
        guard index > 0 else { return nil }
        return makePageViewController(at: index - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let pageVC = viewController as? OnboardingPageViewController else { return nil }
        let next = pageVC.pageIndex + 1
        guard next < Constants.pagesCount else { return nil }
        return makePageViewController(at: next)
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? OnboardingPageViewController else { return }
        currentPageIndex = current.pageIndex
        pageControl.currentPage = current.pageIndex
    }
}

// MARK: - Constants
private extension OnboardingViewController {
    enum Constants {
        // MARK: - State
        static let onboardingCompletedKey = "onboardingCompleted"
        static let pagesCount = 2

        // MARK: - Buttons
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let horizontalPadding: CGFloat = 20
        static let buttonBottomPadding: CGFloat = 50

        // MARK: - Page control
        static let pageControlSpacing: CGFloat = 24
        static let pageControlInactiveAlpha: CGFloat = 0.3
    }

    enum Strings {
        static let page1Title = "Отслеживайте только то, что хотите"
        static let page2Title = "Даже если это не литры воды и йога"
        static let primaryButtonTitle = "Вот это технологии!"
    }
}
