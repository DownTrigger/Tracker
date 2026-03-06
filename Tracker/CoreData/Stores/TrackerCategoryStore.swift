import CoreData

final class TrackerCategoryStore: NSObject {

    // MARK: - Public Properties
    var onChange: (() -> Void)?

    // MARK: - Private Properties
    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()

    // MARK: - Computed Properties
    var categories: [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { makeCategory(from: $0) }
    }

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("TrackerCategoryStore: performFetch failed: \(error)")
        }
    }

    // MARK: - Private Methods
    private func makeCategory(from object: TrackerCategoryCD) -> TrackerCategory? {
        guard let title = object.title else { return nil }
        let trackers = (object.trackers as? Set<TrackerCD>)?.compactMap { $0.toTracker() } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onChange?()
    }
}
