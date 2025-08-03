import Foundation

struct CreateUserRequest: Codable, Sendable, Equatable {
  let username: String
  let email: String?
  let profileImageURL: String?
  
  init(username: String, email: String? = nil, profileImageURL: String? = nil) {
    self.username = username
    self.email = email
    self.profileImageURL = profileImageURL
  }
}

struct UserUpdateRequest: Codable, Sendable, Equatable {
  let username: String?
  let email: String?
  let profileImageURL: String?
  let favoriteCategory: QuizCategory?
  
  init(
    username: String? = nil,
    email: String? = nil,
    profileImageURL: String? = nil,
    favoriteCategory: QuizCategory? = nil
  ) {
    self.username = username
    self.email = email
    self.profileImageURL = profileImageURL
    self.favoriteCategory = favoriteCategory
  }
}
