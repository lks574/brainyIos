import Foundation

struct UserDTO: Codable, Sendable, Equatable {
  let id: String
  let username: String
  let email: String?
  let profileImageURL: String?
  let createdAt: Date
  let updatedAt: Date
  let favoriteCategory: QuizCategory

  // Stage 관련 통계
  let totalStagesCompleted: Int
  let totalStars: Int
  let currentStreak: Int
  let bestStreak: Int
  let overallAccuracy: Double
}

extension UserDTO {
  init(from entity: UserEntity) {
    self.id = entity.id
    self.username = entity.username
    self.email = entity.email
    self.profileImageURL = entity.profileImageURL
    self.createdAt = entity.createdAt
    self.updatedAt = entity.updatedAt
    self.favoriteCategory = QuizCategory(rawValue: entity.favoriteCategory ?? "general") ?? .general
    self.totalStagesCompleted = entity.totalStagesCompleted
    self.totalStars = entity.totalStars
    self.currentStreak = entity.currentStreak
    self.bestStreak = entity.bestStreak
    self.overallAccuracy = entity.overallAccuracy
  }
}

// MARK: - Mock Data
extension UserDTO {
  static let mock = UserDTO(
    id: "user-1",
    username: "테스트유저",
    email: "test@example.com",
    profileImageURL: nil,
    createdAt: Date(),
    updatedAt: Date(),
    favoriteCategory: .general,
    totalStagesCompleted: 15,
    totalStars: 35,
    currentStreak: 3,
    bestStreak: 7,
    overallAccuracy: 0.75
  )
}
