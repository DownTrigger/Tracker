import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {

    private var stack: TestCoreDataStack!

    override func setUp() {
        super.setUp()
        stack = TestCoreDataStack()
        populateTestData()
    }

    override func tearDown() {
        stack = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testTrackersScreen_lightTheme() {
        let vc = makeNavigationController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testTrackersScreen_darkTheme() {
        let vc = makeNavigationController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Helpers

    private func makeNavigationController() -> UINavigationController {
        let viewModel = TrackersViewModel(
            categoryStore: stack.categoryStore,
            trackerStore: stack.trackerStore,
            recordStore: stack.recordStore
        )
        viewModel.setDate(Self.fixedDate)
        let vc = TrackersViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: vc)
    }

    private static let fixedDate: Date = {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components)!
    }()

    private func populateTestData() {
        let allDays = [1, 2, 3, 4, 5, 6, 7]

        try? stack.trackerStore.addTracker(
            Tracker(id: UUID(), name: "Утренняя пробежка", color: 0, emoji: "🏃", schedule: allDays, isPinned: false),
            toCategoryWithTitle: "Спорт"
        )
        try? stack.trackerStore.addTracker(
            Tracker(id: UUID(), name: "Медитация", color: 2, emoji: "🧘", schedule: allDays, isPinned: false),
            toCategoryWithTitle: "Спорт"
        )
        try? stack.trackerStore.addTracker(
            Tracker(id: UUID(), name: "Читать книгу", color: 5, emoji: "📚", schedule: allDays, isPinned: false),
            toCategoryWithTitle: "Саморазвитие"
        )
    }
}
