import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        setupViewControllers()
    }

    // MARK: - Setup
    private func configureTabBarAppearance() {
        let lineHeight: CGFloat = 2.0 / UIScreen.main.scale
        let size = CGSize(width: 1, height: lineHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.separator.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let lineImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.primaryBackground
        appearance.shadowImage = lineImage
        appearance.shadowColor = .separator
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupViewControllers() {
        let stack = CoreDataStack.shared
        let trackersViewModel = TrackersViewModel(
            categoryStore: stack.categoryStore,
            trackerStore: stack.trackerStore,
            recordStore: stack.recordStore
        )
        let trackersViewController = TrackersViewController(viewModel: trackersViewModel, categoryStore: stack.categoryStore)
        let trackersNavController = UINavigationController(rootViewController: trackersViewController)
        trackersViewController.tabBarItem = UITabBarItem(
            title: "tab_trackers".localized,
            image: UIImage(resource: .iconCircle),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let statisticsNavController = UINavigationController(rootViewController: statisticsViewController)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "tab_statistics".localized,
            image: UIImage(resource: .iconHare),
            selectedImage: nil
        )
        viewControllers = [trackersNavController, statisticsNavController]
    }
}
