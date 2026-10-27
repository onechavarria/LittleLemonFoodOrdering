
import Foundation

struct MenuResponse: Decodable {
    let menu: [MenuItem]
}

struct MenuItem: Codable, Identifiable {
    var id: String { name }
    let name: String
    let price: Double
    let description: String
    let image: String
    let category: String

    var imageURL: URL? {
        URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/images/\(image)")
    }

    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
}
