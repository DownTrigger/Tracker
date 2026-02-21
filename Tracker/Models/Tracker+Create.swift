import UIKit

extension Tracker {
    static func create(name: String, schedule: [Int]) -> Tracker {
        let colorIndex = Int.random(in: 0..<TrackerColors.palette.count)
        return Tracker(
            id: UUID(),
            name: name,
            color: colorIndex,
            emoji: TrackerEmojis.random,
            schedule: schedule
        )
    }
}
