import Foundation

struct QuizSessionDTO: Codable, Sendable, Equatable, Identifiable {
  let id: String
  let userId: String
  let category: QuizCategory
  let mode: QuizMode
  let totalQuestions: Int
  let correctAnswers: Int
  let totalTime: TimeInterval
  let startedAt: Date
  let completedAt: Date?
  let accuracy: Double
}

extension QuizSessionDTO {
  init(from entity: QuizSessionEntity) {
    self.id = entity.id
    self.userId = entity.userId
    self.category = entity.category
    self.mode = entity.mode
    self.totalQuestions = entity.totalQuestions
    self.correctAnswers = entity.correctAnswers
    self.totalTime = entity.totalTime
    self.startedAt = entity.startedAt
    self.completedAt = entity.completedAt
    self.accuracy = entity.accuracy
  }
}

// MARK: - Mock Data
extension QuizSessionDTO {
  static let mock = QuizSessionDTO(
    id: "session-1",
    userId: "user-1",
    category: .general,
    mode: .stage,
    totalQuestions: 10,
    correctAnswers: 8,
    totalTime: 120.5,
    startedAt: Date().addingTimeInterval(-300),
    completedAt: Date(),
    accuracy: 0.8
  )
}
