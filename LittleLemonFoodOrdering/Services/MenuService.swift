
import Foundation

struct MenuService {
    private let endpoint = URL(
        string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/capstone.json"
    )!

    func fetchMenu() async throws -> [MenuItem] {
        let (data, response) = try await URLSession.shared.data(from: endpoint)

        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(MenuResponse.self, from: data).menu
    }
}
