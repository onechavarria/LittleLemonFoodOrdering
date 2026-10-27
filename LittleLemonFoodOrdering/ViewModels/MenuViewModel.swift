
import Foundation
import Combine

@MainActor
final class MenuViewModel: ObservableObject {
    @Published var items: [MenuItem] = []
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = MenuService()
    private let database = PersistenceController.shared

    let categories = ["starters", "mains", "desserts", "drinks"]

    var filteredItems: [MenuItem] {
        items.filter { item in
            let matchesCategory = selectedCategory == nil ||
                item.category.lowercased() == selectedCategory

            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
        .sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    func loadMenu() async {
        isLoading = true
        errorMessage = nil

        do {
            items = try database.loadMenu()
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let remoteItems = try await service.fetchMenu()
            try database.saveMenu(remoteItems)
            items = remoteItems.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            errorMessage = nil
        } catch {
            if items.isEmpty {
                errorMessage = "No se pudo cargar el menú. Revisa tu conexión."
            }
        }

        isLoading = false
    }

    func toggleCategory(_ category: String) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
}
