import CoreData

final class TrackerStore {

    // MARK: - Private Properties
    private let context: NSManagedObjectContext

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let category = findOrCreateCategory(title: title)
        let object = TrackerCD(context: context)
        object.id = tracker.id
        object.name = tracker.name
        object.color = Int16(tracker.color)
        object.emoji = tracker.emoji
        object.schedule = try JSONEncoder().encode(tracker.schedule)
        object.category = category
        try context.save()
    }

    func deleteTracker(id: UUID) {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let objects = try context.fetch(request)
            objects.forEach { context.delete($0) }
            try context.save()
        } catch {
            assertionFailure("TrackerStore: deleteTracker failed: \(error)")
        }
    }

    // MARK: - Private Methods
    private func findOrCreateCategory(title: String) -> TrackerCategoryCD {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.predicate = NSPredicate(format: "title == %@", title)
        do {
            if let existing = try context.fetch(request).first {
                return existing
            }
        } catch {
            assertionFailure("TrackerStore: findOrCreateCategory fetch failed: \(error)")
        }
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.id = UUID()
        newCategory.title = title
        return newCategory
    }
}
