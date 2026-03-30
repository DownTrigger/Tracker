import CoreData

final class TrackerRecordStore: NSObject {

    // MARK: - Public Properties
    var onChange: (() -> Void)?

    // MARK: - Private Properties
    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCD> = {
        let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
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
    var records: [TrackerRecord] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { makeRecord(from: $0) }
    }

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("TrackerRecordStore: performFetch failed: \(error)")
        }
    }

    // MARK: - Public Methods
    func addRecord(_ record: TrackerRecord) {
        let object = TrackerRecordCD(context: context)
        object.id = UUID()
        object.trackerId = record.trackerId
        object.date = record.date
        do {
            try context.save()
        } catch {
            assertionFailure("TrackerRecordStore: addRecord save failed: \(error)")
        }
    }

    func deleteRecord(trackerId: UUID, date: Date) {
        let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        let calendar = Calendar.current
        do {
            let objects = try context.fetch(request)
            objects.filter { calendar.isDate($0.date ?? .distantPast, inSameDayAs: date) }
                   .forEach { context.delete($0) }
            try context.save()
        } catch {
            assertionFailure("TrackerRecordStore: deleteRecord failed: \(error)")
        }
    }

    // MARK: - Private Methods
    private func makeRecord(from object: TrackerRecordCD) -> TrackerRecord? {
        guard let trackerId = object.trackerId, let date = object.date else { return nil }
        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onChange?()
    }
}
