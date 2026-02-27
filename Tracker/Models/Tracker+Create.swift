import UIKit

extension Tracker {

    // MARK: - Factory
    static func create(name: String, schedule: [Int], emoji: String, colorIndex: Int) -> Tracker {
        Tracker(
            id: UUID(),
            name: name,
            color: colorIndex,
            emoji: emoji,
            schedule: schedule
        )
    }
}
