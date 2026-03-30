import Foundation

final class TrackerTypeSelectionViewModel {
    var onHabitSelected: (() -> Void)?
    var onIrregularSelected: (() -> Void)?

    func habitChosen() { onHabitSelected?() }
    func irregularChosen() { onIrregularSelected?() }
}
