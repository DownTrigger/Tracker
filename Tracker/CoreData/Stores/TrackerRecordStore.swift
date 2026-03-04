import CoreData

final class TrackerRecordStore: NSObject {
    var onChange: (() -> Void)?

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

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("TrackerRecordStore: performFetch failed: \(error)")
        }
    }

    var records: [TrackerRecord] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { makeRecord(from: $0) }
    }

    func addRecord(_ record: TrackerRecord) {
        let object = TrackerRecordCD(context: context)
        object.id = UUID()
        object.trackerId = record.trackerId
        object.date = record.date
        try? context.save()
    }

    func deleteRecord(trackerId: UUID, date: Date) {
        let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        let calendar = Calendar.current
        ((try? context.fetch(request)) ?? [])
            .filter { calendar.isDate($0.date ?? .distantPast, inSameDayAs: date) }
            .forEach { context.delete($0) }
        try? context.save()
    }

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
