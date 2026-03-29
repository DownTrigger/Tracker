import UIKit

final class IrregularEventCreationViewController: TrackerCreationViewController {

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        super.init(viewModel: TrackerCreationViewModel(categoryStore: categoryStore))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides
    override var screenTitle: String { Self.Strings.screenTitle }

    override var emojiToColorSectionSpacing: CGFloat { 4 }

    override func performCreate() {
        guard let categoryTitle = viewModel.selectedCategoryTitle else { return }
        let tracker = viewModel.buildTracker(schedule: WeekDay.fullWeekSchedule)
        onCreateTracker?(tracker, categoryTitle)
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - Strings
private extension IrregularEventCreationViewController {
    enum Strings {
        static let screenTitle = "Новое нерегулярное событие"
    }
}
