struct CreateUserRequest: Sendable {
  let email: String?
  let displayName: String
  let authProvider: AuthType
}

struct UserUpdateRequest: Sendable {
  let displayName: String
}
