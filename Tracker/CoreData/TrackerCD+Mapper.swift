import CoreData

extension TrackerCD {
    func toTracker() -> Tracker? {
        guard
            let id = id,
            let name = name,
            let emoji = emoji,
            let scheduleData = schedule,
            let schedule = try? JSONDecoder().decode([Int].self, from: scheduleData)
        else { return nil }
        return Tracker(id: id, name: name, color: Int(color), emoji: emoji, schedule: schedule)
    }
}
