import ComposableArchitecture

@DependencyClient
struct UserClient {
  var createUser: @Sendable (CreateUserRequest) async throws -> UserDTO
  var fetchUsers: @Sendable () async throws -> [UserDTO]
  var fetchUser: @Sendable (String) async throws -> UserDTO?
  var updateUser: @Sendable (String, UserUpdateRequest) async throws -> UserDTO?
  var updateUserStats: @Sendable (String, UserStatsUpdateRequest) async throws -> UserDTO?
  var deleteUser: @Sendable (String) async throws -> Bool
  var getCurrentUser: @Sendable () async throws -> UserDTO?
}

extension UserClient: DependencyKey {
  static let liveValue: UserClient = {
    return UserClient(
      createUser: { req in
        try SwiftDataManager().createUser(req)
      },
      fetchUsers: {
        try SwiftDataManager().fetchUsers()
      },
      fetchUser: { id in
        try SwiftDataManager().fetchUser(by: id)
      },
      updateUser: { id, req in
        try SwiftDataManager().updateUser(id: id, with: req)
      },
      updateUserStats: { id, req in
        try SwiftDataManager().updateUserStats(id: id, with: req)
      },
      deleteUser: { id in
        try SwiftDataManager().deleteUser(id: id)
      },
      getCurrentUser: {
        try SwiftDataManager().getCurrentUser()
      }
    )
  }()
}

extension DependencyValues {
  var userClient: UserClient {
    get { self[UserClient.self] }
    set { self[UserClient.self] = newValue }
  }
}

// MARK: - Test Implementation
extension UserClient {
  static let testValue = UserClient(
    createUser: { _ in .mock },
    fetchUsers: { [.mock] },
    fetchUser: { _ in .mock },
    updateUser: { _, _ in .mock },
    updateUserStats: { _, _ in .mock },
    deleteUser: { _ in true },
    getCurrentUser: { .mock }
  )
  
  static let previewValue = testValue
}