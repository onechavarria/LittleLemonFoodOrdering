
import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()

        entity.name = "MenuEntity"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let name = Self.makeAttribute("name", .stringAttributeType)
        let description = Self.makeAttribute("itemDescription", .stringAttributeType)
        let image = Self.makeAttribute("image", .stringAttributeType)
        let category = Self.makeAttribute("category", .stringAttributeType)
        let price = Self.makeAttribute("price", .doubleAttributeType)

        entity.properties = [name, description, image, category, price]
        entity.uniquenessConstraints = [["name"]]
        model.entities = [entity]

        container = NSPersistentContainer(
            name: "LittleLemonDatabase",
            managedObjectModel: model
        )

        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data error: \(error.localizedDescription)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func makeAttribute(
        _ name: String,
        _ type: NSAttributeType
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = false
        return attribute
    }

    func saveMenu(_ items: [MenuItem]) throws {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "MenuEntity")
        let existing = try context.fetch(request)

        existing.forEach { context.delete($0) }

        for item in items {
            let object = NSEntityDescription.insertNewObject(
                forEntityName: "MenuEntity",
                into: context
            )

            object.setValue(item.name, forKey: "name")
            object.setValue(item.description, forKey: "itemDescription")
            object.setValue(item.image, forKey: "image")
            object.setValue(item.category, forKey: "category")
            object.setValue(item.price, forKey: "price")
        }

        try context.save()
    }

    func loadMenu() throws -> [MenuItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "MenuEntity")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return try container.viewContext.fetch(request).map { object in
            MenuItem(
                name: object.value(forKey: "name") as? String ?? "",
                price: object.value(forKey: "price") as? Double ?? 0,
                description: object.value(forKey: "itemDescription") as? String ?? "",
                image: object.value(forKey: "image") as? String ?? "",
                category: object.value(forKey: "category") as? String ?? ""
            )
        }
    }
}
