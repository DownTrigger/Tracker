import XCTest
import SnapshotTesting
@testable import Tracker

final class OnboardingSnapshotTests: XCTestCase {

    func testOnboardingScreen_lightTheme() {
        let vc = makeVC()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testOnboardingScreen_darkTheme() {
        let vc = makeVC()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeVC() -> OnboardingViewController {
        OnboardingViewController()
    }
}
