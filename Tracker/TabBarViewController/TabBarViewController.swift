import UIKit

final class TabBarViewController: UITabBarController {

// MARK: - Lifecycle
override func viewDidLoad() {
    super.viewDidLoad()
    configureTabBarAppearance()
    setupViewControllers()
}

// MARK: - Appearance
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
    appearance.shadowImage = lineImage
    appearance.shadowColor = .separator
    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
}

// MARK: - Setup
private func setupViewControllers() {
    let trackersViewController = TrackersViewController()
    let trackersNavController = UINavigationController(rootViewController: trackersViewController)

    trackersViewController.view.backgroundColor = UIColor(resource: .anyScreenBackground )
    trackersViewController.tabBarItem = UITabBarItem(
        title: "Трекеры",
        image: UIImage(resource: .iconCircle),
        selectedImage: nil
    )

    let statisticsViewController = StatisticsViewController()
    let statisticsNavControler = UINavigationController(rootViewController: statisticsViewController)

    statisticsViewController.view.backgroundColor = UIColor(resource: .anyScreenBackground )
    statisticsViewController.tabBarItem = UITabBarItem(
        title: "Статистика",
        image: UIImage(resource: .iconHare),
        selectedImage: nil
    )

    self.viewControllers = [trackersNavController, statisticsNavControler]
}

}
