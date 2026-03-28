import UIKit

final class OnboardingViewModel {

    // MARK: - State
    let pages: [PageContent]
    private(set) var currentPageIndex: Int = 0

    // MARK: - Bindings
    var onCurrentPageChanged: ((Int) -> Void)?

    // MARK: - Init
    init() {
        pages = [
            PageContent(
                title: "Отслеживайте только то, что хотите",
                image: UIImage(resource: .blueBackground)
            ),
            PageContent(
                title: "Даже если это не литры воды и йога",
                image: UIImage(resource: .redBackground)
            )
        ]
    }

    // MARK: - Methods
    func setCurrentPage(_ index: Int) {
        currentPageIndex = index
        onCurrentPageChanged?(index)
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: Constants.onboardingCompletedKey)
    }

    static func isCompleted() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.onboardingCompletedKey)
    }

    // MARK: - Constants
    private enum Constants {
        static let onboardingCompletedKey = "onboardingCompleted"
    }
}
