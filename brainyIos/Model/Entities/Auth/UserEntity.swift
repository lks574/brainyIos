import Foundation
import SwiftData

@Model
final class UserEntity {
  @Attribute(.unique) var id: String
  var username: String
  var email: String?
  var profileImageURL: String?
  var createdAt: Date
  var updatedAt: Date
  
  // 퀴즈 관련 통계
  var totalQuizzesTaken: Int = 0
  var totalCorrectAnswers: Int = 0
  var favoriteCategory: QuizCategory?
  var currentStreak: Int = 0
  var bestStreak: Int = 0
  
  // 관계
  @Relationship(deleteRule: .cascade) var quizSessions: [QuizSessionEntity] = []
  @Relationship(deleteRule: .cascade) var quizResults: [QuizResultEntity] = []
  
  init(id: String, username: String, email: String? = nil, profileImageURL: String? = nil) {
    self.id = id
    self.username = username
    self.email = email
    self.profileImageURL = profileImageURL
    self.createdAt = Date()
    self.updatedAt = Date()
  }
  
  /// 전체 정확도 계산
  var overallAccuracy: Double {
    guard totalQuizzesTaken > 0 else { return 0 }
    return Double(totalCorrectAnswers) / Double(totalQuizzesTaken)
  }
  
  /// 업데이트 시간 갱신
  func updateTimestamp() {
    self.updatedAt = Date()
  }
}