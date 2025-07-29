import ComposableArchitecture

@DependencyClient
struct SwiftDataClient {
  var createUser: @Sendable (CreateUserRequest) async throws -> UserDTO
  var fetchUsers: @Sendable () async throws -> [UserDTO]
  var fetchUser: @Sendable (String) async throws -> UserDTO?
  var updateUser: @Sendable (String, UserUpdateRequest) async throws -> UserDTO?
  var deleteUser: @Sendable (String) async throws -> Bool
}

extension SwiftDataClient: DependencyKey {
  static let liveValue: SwiftDataClient = {
    return SwiftDataClient(
      createUser: { req in
        try SwiftDataManager().createUser(req)
      },
      fetchUsers: {
        try SwiftDataManager().fetchUsers()
      },
      fetchUser: { req in
        try SwiftDataManager().fetchUser(by: req)
      },
      updateUser: { id, req in
        try SwiftDataManager().updateUser(id: id, with: req)
      },
      deleteUser: { id in
        try SwiftDataManager().deleteUser(id: id)
      }
    )
  }()
}

extension DependencyValues {
  var swiftDataClient: SwiftDataClient {
    get { self[SwiftDataClient.self] }
    set { self[SwiftDataClient.self] = newValue }
  }
}
