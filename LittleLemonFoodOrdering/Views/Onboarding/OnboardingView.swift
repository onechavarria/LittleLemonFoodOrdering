
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var storage: ProfileStorage

    @State private var page = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var showError = false

    private var validForm: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        email.split(separator: "@").last?.contains(".") == true
    }

    var body: some View {
        VStack(spacing: 0) {
            LittleLemonHeader()

            ScrollView {
                VStack(spacing: 24) {
                    HeroView()

                    if page == 0 {
                        introduction
                    } else if page == 1 {
                        features
                    } else {
                        registration
                    }

                    Spacer(minLength: 20)

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule()
                                .fill(
                                    page == index
                                    ? LemonColors.green
                                    : LemonColors.lightGray
                                )
                                .frame(
                                    width: page == index ? 28 : 9,
                                    height: 9
                                )
                        }
                    }

                    HStack(spacing: 12) {
                        if page > 0 {
                            Button("Atrás") {
                                page -= 1
                            }
                            .buttonStyle(.bordered)
                            .tint(LemonColors.green)
                        }

                        Button(page == 2 ? "Registrarse" : "Siguiente") {
                            if page < 2 {
                                page += 1
                            } else {
                                register()
                            }
                        }
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(LemonColors.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 25)
            }
        }
        .background(.white)
        .alert("Datos incompletos", isPresented: $showError) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Completa tu nombre, apellido y un correo electrónico válido.")
        }
    }

    private var introduction: some View {
        VStack(spacing: 18) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(LemonColors.green)

            Text("Bienvenido a Little Lemon")
                .font(.title2.bold())

            Text("Descubre nuestra cocina mediterránea y explora deliciosos platos preparados para ti.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(25)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 24) {
            feature(
                "magnifyingglass",
                "Busca tus platos",
                "Encuentra tus comidas favoritas rápidamente."
            )

            feature(
                "line.3.horizontal.decrease.circle",
                "Explora categorías",
                "Filtra por entradas, platos principales, postres y bebidas."
            )

            feature(
                "person.crop.circle",
                "Personaliza tu perfil",
                "Guarda tus datos y preferencias."
            )
        }
        .padding(25)
    }

    private func feature(
        _ symbol: String,
        _ title: String,
        _ detail: String
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.title)
                .foregroundStyle(LemonColors.green)
                .frame(width: 45)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var registration: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Crear perfil")
                .font(.title2.bold())

            Text("Introduce tus datos personales para continuar.")
                .foregroundStyle(.secondary)

            field("Nombre *", text: $firstName)
                .textContentType(.givenName)

            field("Apellido *", text: $lastName)
                .textContentType(.familyName)

            field("Correo electrónico *", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            field("Teléfono", text: $phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
        }
        .padding(20)
    }

    private func field(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func register() {
        guard validForm else {
            showError = true
            return
        }

        var profile = UserProfile()
        profile.firstName = firstName.trimmingCharacters(in: .whitespaces)
        profile.lastName = lastName.trimmingCharacters(in: .whitespaces)
        profile.email = email.trimmingCharacters(in: .whitespaces)
        profile.phoneNumber = phone
        profile.isRegistered = true

        storage.save(profile)
    }
}
