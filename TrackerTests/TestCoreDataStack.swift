import CoreData
@testable import Tracker

final class TestCoreDataStack {

    let persistentContainer: NSPersistentContainer

    lazy var trackerStore = TrackerStore(context: context)
    lazy var categoryStore = TrackerCategoryStore(context: context)
    lazy var recordStore = TrackerRecordStore(context: context)

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                preconditionFailure("TestCoreDataStack failed to load: \(error)")
            }
        }
    }
}
