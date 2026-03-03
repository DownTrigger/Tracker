import UIKit

final class IrregularEventCreationViewController: TrackerCreationViewController {

    // MARK: - Overrides
    override var screenTitle: String { Self.Strings.screenTitle }

    override var emojiToColorSectionSpacing: CGFloat { 4 }

    override func performCreate() {
        let tracker = Tracker.create(name: trimmedName, schedule: WeekDay.fullWeekSchedule, emoji: selectedEmoji, colorIndex: selectedColorIndex)
        onCreateTracker?(tracker)
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - Strings
private extension IrregularEventCreationViewController {
    enum Strings {
        static let screenTitle = "Новое нерегулярное событие"
    }
}
