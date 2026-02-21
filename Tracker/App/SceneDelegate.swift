import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let completed = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        window?.rootViewController = completed ? TabBarViewController() : OnboardingViewController()
        window?.makeKeyAndVisible()
    }
}

