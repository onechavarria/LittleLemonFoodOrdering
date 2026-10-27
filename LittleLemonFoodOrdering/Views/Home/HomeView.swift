
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LittleLemonHeader(
                    onProfile: {
                        showProfile = true
                    }
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HeroView()

                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)

                        menuContent
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .background(.white)
            }
            .background(.white)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
                    .navigationBarBackButtonHidden()
            }
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.loadMenu()
                }
            }
        }
        .tint(LemonColors.green)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19))
                .foregroundStyle(LemonColors.green)

            TextField("Buscar platos...", text: $viewModel.searchText)
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(LemonColors.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var menuContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ORDER FOR DELIVERY!")
                .font(.system(size: 21, weight: .heavy))
                .foregroundStyle(.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        categoryButton(category)
                    }
                }
                .padding(.vertical, 2)
            }

            Divider()

            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView("Cargando menú...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else if let message = viewModel.errorMessage,
                      viewModel.items.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.largeTitle)

                    Text(message)
                        .multilineTextAlignment(.center)

                    Button("Reintentar") {
                        Task {
                            await viewModel.loadMenu()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(LemonColors.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)

            } else if viewModel.filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(LemonColors.green)

                    Text("No se encontraron platos")
                        .font(.headline)

                    Text("Prueba otra búsqueda o categoría.")
                        .foregroundStyle(.secondary)

                    Button("Mostrar todos") {
                        viewModel.searchText = ""
                        viewModel.selectedCategory = nil
                    }
                    .tint(LemonColors.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 35)

            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredItems) { item in
                        menuRow(item)

                        Divider()
                    }
                }
            }
        }
    }

    private func categoryButton(_ category: String) -> some View {
        let selected = viewModel.selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleCategory(category)
            }
        } label: {
            Text(category.capitalized)
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(
                    selected ? LemonColors.green : LemonColors.lightGray
                )
                .foregroundStyle(
                    selected ? .white : LemonColors.green
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func menuRow(_ item: MenuItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text(item.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)

                Text(item.description)
                    .font(.system(size: 15))
                    .foregroundStyle(LemonColors.green)
                    .lineLimit(2)

                Text(item.formattedPrice)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(LemonColors.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AsyncImage(url: item.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(LemonColors.lightGray)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(LemonColors.green)
                    }
            }
            .frame(width: 95, height: 95)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    HomeView()
        .environmentObject(ProfileStorage())
}
