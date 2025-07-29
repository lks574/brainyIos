import Foundation
import SwiftData

@Model
final class UserEntity {
  @Attribute(.unique) var id: String
  var email: String?
  var displayName: String
  var authProvider: AuthType
  var createdAt: Date
  var lastSyncAt: Date?

  init(email: String? = nil, displayName: String, authProvider: AuthType) {
    self.id = UUID().uuidString
    self.email = email
    self.displayName = displayName
    self.authProvider = authProvider
    self.createdAt = Date()
  }
}
