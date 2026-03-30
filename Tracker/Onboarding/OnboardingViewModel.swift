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
            PageContent(title: "Отслеживайте только то, что хотите", image: .blueBackground),
            PageContent(title: "Даже если это не литры воды и йога", image: .redBackground)
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
