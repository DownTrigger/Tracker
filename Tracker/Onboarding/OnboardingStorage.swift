import Foundation

final class OnboardingStorage {

    // MARK: - Private
    private enum Keys {
        static let completed = "onboardingCompleted"
    }

    // MARK: - Methods
    func markCompleted() {
        UserDefaults.standard.set(true, forKey: Keys.completed)
    }

    func isCompleted() -> Bool {
        UserDefaults.standard.bool(forKey: Keys.completed)
    }
}
