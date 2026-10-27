
import Foundation

struct UserProfile: Codable, Equatable {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phoneNumber = ""
    var isRegistered = false
    var orderStatuses = true
    var passwordChanges = true
    var specialOffers = true
    var newsletter = true
}
