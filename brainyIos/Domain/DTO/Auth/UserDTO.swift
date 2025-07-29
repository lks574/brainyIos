import SwiftUI

struct UserDTO: Sendable, Equatable, Identifiable {
  let id: String
  let email: String?
  let displayName: String
  let authProvider: AuthType
  let createdAt: Date
  let lastSyncAt: Date?

  init(from user: UserEntity) {
    self.id = user.id
    self.email = user.email
    self.displayName = user.displayName
    self.authProvider = user.authProvider
    self.createdAt = user.createdAt
    self.lastSyncAt = user.lastSyncAt
  }
}
