import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

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

    private func findOrCreateCategory(title: String) -> TrackerCategoryCD {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try? context.fetch(request).first {
            return existing
        }
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.id = UUID()
        newCategory.title = title
        return newCategory
    }
}
