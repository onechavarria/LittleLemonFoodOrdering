
import SwiftUI

@main
struct LittleLemonFoodOrderingApp: App {
    @StateObject private var profileStorage = ProfileStorage()

    var body: some Scene {
        WindowGroup {
            Group {
                if profileStorage.profile.isRegistered {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(profileStorage)
            .preferredColorScheme(.light)
        }
    }
}
