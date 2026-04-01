import XCTest
import SnapshotTesting
@testable import Tracker

final class FiltersSnapshotTests: XCTestCase {

    func testFiltersScreen_lightTheme() {
        let vc = makeVC(activeFilter: .today)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testFiltersScreen_darkTheme() {
        let vc = makeVC(activeFilter: .today)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeVC(activeFilter: TrackerFilter) -> UINavigationController {
        let viewModel = FiltersViewModel(activeFilter: activeFilter)
        let vc = FiltersViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: vc)
    }
}
