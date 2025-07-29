import Combine
import Foundation
import SwiftData

final class SwiftDataManager: ObservableObject {
  private let modelContainer: ModelContainer
  private let modelContext: ModelContext

  init() throws {
    let schema = Schema([
      UserEntity.self,
    ])

    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false)

    self.modelContainer = try ModelContainer(
      for: schema,
      configurations: [modelConfiguration]
    )

    self.modelContext = ModelContext(modelContainer)
  }

  func createUser(_ req: CreateUserRequest) throws -> UserDTO {
    let user = UserEntity(
      email: req.email,
      displayName: req.displayName,
      authProvider: req.authProvider)
    modelContext.insert(user)
    try modelContext.save()
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

    user.displayName = req.displayName

    try modelContext.save()
    return UserDTO(from: user)
  }

  func deleteUser(id: String) throws -> Bool {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return false }

    modelContext.delete(user)
    try modelContext.save()
    return true
  }
}
