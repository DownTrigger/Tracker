import XCTest
import SnapshotTesting
@testable import Tracker

final class StatisticsSnapshotTests: XCTestCase {

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

    func testStatisticsScreen_lightTheme() {
        let vc = makeVC()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testStatisticsScreen_darkTheme() {
        let vc = makeVC()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeVC() -> UINavigationController {
        let viewModel = StatisticsViewModel(recordStore: stack.recordStore, categoryStore: stack.categoryStore)
        let vc = StatisticsViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: vc)
    }

    private func populateTestData() {
        let trackerId = UUID()
        let calendar = Calendar.current
        for daysAgo in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                stack.recordStore.addRecord(TrackerRecord(trackerId: trackerId, date: date))
            }
        }
    }
}
