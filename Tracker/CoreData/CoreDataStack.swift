import CoreData

final class CoreDataStack {

    // MARK: - Singleton
    static let shared = CoreDataStack()
    private init() { }

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Core Data failed to load: \(error)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Stores
    lazy var trackerStore = TrackerStore(context: context)
    lazy var categoryStore = TrackerCategoryStore(context: context)
    lazy var recordStore = TrackerRecordStore(context: context)

    // MARK: - Save
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("Core Data save failed: \(error)")
        }
    }
}
