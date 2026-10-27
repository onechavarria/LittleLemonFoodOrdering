
import Foundation
import Combine

@MainActor
final class ProfileStorage: ObservableObject {
    @Published private(set) var profile: UserProfile
    @Published private(set) var avatarData: Data?

    private let profileKey = "littleLemonUserProfile"
    private let avatarKey = "littleLemonUserAvatar"

    init() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
        } else {
            profile = UserProfile()
        }

        avatarData = UserDefaults.standard.data(forKey: avatarKey)
    }

    func save(_ newProfile: UserProfile) {
        profile = newProfile

        if let data = try? JSONEncoder().encode(newProfile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    func saveAvatar(_ data: Data?) {
        avatarData = data

        if let data {
            UserDefaults.standard.set(data, forKey: avatarKey)
        } else {
            UserDefaults.standard.removeObject(forKey: avatarKey)
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.removeObject(forKey: avatarKey)

        profile = UserProfile()
        avatarData = nil
    }
}
