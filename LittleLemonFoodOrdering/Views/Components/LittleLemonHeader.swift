
import SwiftUI

enum LemonColors {
    static let green = Color(
        red: 73 / 255,
        green: 94 / 255,
        blue: 87 / 255
    )

    static let yellow = Color(
        red: 244 / 255,
        green: 206 / 255,
        blue: 20 / 255
    )

    static let lightGray = Color(
        red: 237 / 255,
        green: 239 / 255,
        blue: 238 / 255
    )
}

struct LittleLemonHeader: View {
    var showBack = false
    var onBack: (() -> Void)? = nil
    var onProfile: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if showBack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(LemonColors.green)
                }
                .frame(width: 38)
            } else {
                Color.clear.frame(width: 38)
            }

            Spacer(minLength: 0)

            if UIImage(named: "Logo") != nil {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 195, maxHeight: 52)
            } else {
                HStack(spacing: 8) {
                    Text("🍋")
                        .font(.system(size: 27))

                    Text("LITTLE LEMON")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .tracking(2)
                        .foregroundStyle(LemonColors.green)
                }
            }

            Spacer(minLength: 0)

            if let onProfile {
                Button(action: onProfile) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(LemonColors.green)
                }
                .frame(width: 38)
                .accessibilityLabel("Abrir perfil")
            } else {
                Color.clear.frame(width: 38)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 70)
        .background(.white)
    }
}
