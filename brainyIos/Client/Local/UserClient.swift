import ComposableArchitecture

@DependencyClient
struct UserClient {
  var createUser: @Sendable (CreateUserRequest) async throws -> UserDTO
  var fetchUsers: @Sendable () async throws -> [UserDTO]
  var fetchUser: @Sendable (String) async throws -> UserDTO?
  var updateUser: @Sendable (String, UserUpdateRequest) async throws -> UserDTO?
  var deleteUser: @Sendable (String) async throws -> Bool
  var getCurrentUser: @Sendable () async throws -> UserDTO?
}

extension UserClient: DependencyKey {
  static let liveValue: UserClient = {
    let repository = UserRepository()
    return UserClient(
      createUser: { req in
        try repository.createUser(req)
      },
      fetchUsers: {
        try repository.fetchUsers()
      },
      fetchUser: { id in
        try repository.fetchUser(by: id)
      },
      updateUser: { id, req in
        try repository.updateUser(id: id, with: req)
      },
      deleteUser: { id in
        try repository.deleteUser(id: id)
      },
      getCurrentUser: {
        try repository.getCurrentUser()
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
    deleteUser: { _ in true },
    getCurrentUser: { .mock }
  )
  
  static let previewValue = testValue
}
