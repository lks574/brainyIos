import Foundation
import SwiftData

final class UserRepository {
  private let dataManager: SwiftDataManager
  private var modelContext: ModelContext { dataManager.modelContext }

  init(dataManager: SwiftDataManager = .shared) {
    self.dataManager = dataManager
  }

  func createUser(_ req: CreateUserRequest) throws -> UserDTO {
    let user = UserEntity(
      id: UUID().uuidString,
      username: req.username,
      email: req.email,
      profileImageURL: req.profileImageURL
    )
    modelContext.insert(user)
    try dataManager.save()
    return UserDTO(from: user)
  }

  func fetchUsers() throws -> [UserDTO] {
    let descriptor = FetchDescriptor<UserEntity>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    let users = try modelContext.fetch(descriptor)
    return users.map { UserDTO(from: $0) }
  }

  func fetchUser(by id: String) throws -> UserDTO? {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return nil }
    return UserDTO(from: user)
  }

  func updateUser(id: String, with req: UserUpdateRequest) throws -> UserDTO? {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return nil }

    if let username = req.username {
      user.username = username
    }
    if let email = req.email {
      user.email = email
    }
    if let profileImageURL = req.profileImageURL {
      user.profileImageURL = profileImageURL
    }
    if let favoriteCategory = req.favoriteCategory {
      user.favoriteCategory = favoriteCategory.rawValue
    }

    user.updateTimestamp()
    try dataManager.save()
    return UserDTO(from: user)
  }

  func getCurrentUser() throws -> UserDTO? {
    let descriptor = FetchDescriptor<UserEntity>(
      sortBy: [SortDescriptor(\.createdAt, order: .forward)]
    )
    guard let user = try modelContext.fetch(descriptor).first else { return nil }
    return UserDTO(from: user)
  }

  func deleteUser(id: String) throws -> Bool {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return false }

    modelContext.delete(user)
    try dataManager.save()
    return true
  }
}
