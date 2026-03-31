import Foundation

final class OnboardingViewModel {

    // MARK: - State
    let pages: [PageContent]
    private(set) var currentPageIndex: Int = 0

    // MARK: - Bindings
    var onCurrentPageChanged: ((Int) -> Void)?
    var onCompleted: (() -> Void)?

    // MARK: - Dependencies
    private let storage: OnboardingStorage

    // MARK: - Init
    init(storage: OnboardingStorage = OnboardingStorage()) {
        self.storage = storage
        pages = [
            PageContent(title: "onboarding_page1_title".localized, image: .blueBackground),
            PageContent(title: "onboarding_page2_title".localized, image: .redBackground)
        ]
    }

    // MARK: - Methods
    func setCurrentPage(_ index: Int) {
        currentPageIndex = index
        onCurrentPageChanged?(index)
    }

    func completeOnboarding() {
        storage.markCompleted()
        onCompleted?()
    }
}
