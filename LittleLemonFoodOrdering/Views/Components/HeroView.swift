
import SwiftUI

struct HeroView: View {
    private let remoteImage = URL(
        string: "https://images.unsplash.com/photo-1547592180-85f173990554?w=600"
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Little Lemon")
                .font(.system(size: 43, weight: .bold, design: .serif))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(LemonColors.yellow)

            Text("Chicago")
                .font(.system(size: 29, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            HStack(alignment: .center, spacing: 14) {
                Text(
                    "We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist."
                )
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

                Group {
                    if UIImage(named: "Hero") != nil {
                        Image("Hero")
                            .resizable()
                            .scaledToFill()
                    } else {
                        AsyncImage(url: remoteImage) { image in
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
                    }
                }
                .frame(width: 125, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 7)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LemonColors.green)
    }
}

#Preview {
    HeroView()
}
