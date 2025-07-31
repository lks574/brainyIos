import Foundation

struct UserDTO: Codable, Sendable, Equatable {
  let id: String
  let username: String
  let email: String?
  let profileImageURL: String?
  let createdAt: Date
  let updatedAt: Date
  
  // 퀴즈 통계
  let totalQuizzesTaken: Int
  let totalCorrectAnswers: Int
  let favoriteCategory: QuizCategory?
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
    self.totalQuizzesTaken = entity.totalQuizzesTaken
    self.totalCorrectAnswers = entity.totalCorrectAnswers
    self.favoriteCategory = entity.favoriteCategory
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
    totalQuizzesTaken: 50,
    totalCorrectAnswers: 35,
    favoriteCategory: .general,
    currentStreak: 3,
    bestStreak: 7,
    overallAccuracy: 0.7
  )
}