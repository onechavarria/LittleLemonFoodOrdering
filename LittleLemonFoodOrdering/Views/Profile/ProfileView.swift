
import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var storage: ProfileStorage
    @Environment(\.dismiss) private var dismiss

    @State private var draft = UserProfile()
    @State private var draftAvatarData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    @State private var showSaved = false
    @State private var showLogout = false
    @State private var showInvalidData = false

    var body: some View {
        VStack(spacing: 0) {
            LittleLemonHeader(
                showBack: true,
                onBack: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Personal information")
                        .font(.title3.bold())
                        .foregroundStyle(LemonColors.green)

                    avatarSection

                    profileField("First name", text: $draft.firstName)
                        .textContentType(.givenName)

                    profileField("Last name", text: $draft.lastName)
                        .textContentType(.familyName)

                    profileField("Email", text: $draft.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    profileField("Phone number", text: $draft.phoneNumber)
                        .keyboardType(.phonePad)

                    notificationSection

                    Button {
                        showLogout = true
                    } label: {
                        Text("Log out")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(LemonColors.yellow)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }

                    HStack(spacing: 12) {
                        Button {
                            discardChanges()
                        } label: {
                            Text("Discard changes")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(LemonColors.green, lineWidth: 1)
                                }
                        }
                        .foregroundStyle(LemonColors.green)

                        Button {
                            saveChanges()
                        } label: {
                            Text("Save changes")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(LemonColors.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                    }
                    .padding(.bottom, 25)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            discardChanges()
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                    draftAvatarData = data
                }
            }
        }
        .alert("Cambios guardados", isPresented: $showSaved) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Tu perfil se actualizó correctamente.")
        }
        .alert("Datos no válidos", isPresented: $showInvalidData) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Introduce tu nombre, apellido y un correo electrónico válido.")
        }
        .confirmationDialog(
            "¿Quieres cerrar sesión?",
            isPresented: $showLogout,
            titleVisibility: .visible
        ) {
            Button("Cerrar sesión", role: .destructive) {
                storage.logout()
                dismiss()
            }

            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se eliminarán los datos personales y la fotografía guardada.")
        }
    }

    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Avatar")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 17) {
                avatarImage

                VStack(alignment: .leading, spacing: 10) {
                    Text(
                        draft.firstName.isEmpty
                        ? "Usuario"
                        : draft.firstName
                    )
                    .font(.headline)

                    HStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {
                            Text("Change")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(LemonColors.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }

                        Button {
                            selectedPhoto = nil
                            draftAvatarData = nil
                        } label: {
                            Text("Remove")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(LemonColors.green)
                                }
                        }
                        .foregroundStyle(LemonColors.green)
                    }
                }
            }
        }
    }

    private var avatarImage: some View {
        Group {
            if let data = draftAvatarData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(LemonColors.green)
            }
        }
        .frame(width: 75, height: 75)
        .clipShape(Circle())
    }

    private func profileField(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Email notifications")
                .font(.headline)
                .foregroundStyle(LemonColors.green)

            Toggle("Order statuses", isOn: $draft.orderStatuses)
            Toggle("Password changes", isOn: $draft.passwordChanges)
            Toggle("Special offers", isOn: $draft.specialOffers)
            Toggle("Newsletter", isOn: $draft.newsletter)
        }
        .tint(LemonColors.green)
    }

    private func saveChanges() {
        let first = draft.firstName.trimmingCharacters(in: .whitespaces)
        let last = draft.lastName.trimmingCharacters(in: .whitespaces)
        let email = draft.email.trimmingCharacters(in: .whitespaces)

        guard !first.isEmpty,
              !last.isEmpty,
              email.contains("@"),
              email.split(separator: "@").last?.contains(".") == true else {
            showInvalidData = true
            return
        }

        draft.firstName = first
        draft.lastName = last
        draft.email = email

        storage.save(draft)
        storage.saveAvatar(draftAvatarData)
        showSaved = true
    }

    private func discardChanges() {
        draft = storage.profile
        draftAvatarData = storage.avatarData
        selectedPhoto = nil
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(ProfileStorage())
    }
}
