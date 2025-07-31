import Foundation

struct CreateQuizSessionRequest: Codable, Sendable, Equatable {
  let userId: String
  let category: QuizCategory
  let mode: QuizMode
  let totalQuestions: Int
  
  init(
    userId: String,
    category: QuizCategory,
    mode: QuizMode,
    totalQuestions: Int
  ) {
    self.userId = userId
    self.category = category
    self.mode = mode
    self.totalQuestions = totalQuestions
  }
}

struct UpdateQuizSessionRequest: Codable, Sendable, Equatable {
  let correctAnswers: Int?
  let totalTime: TimeInterval?
  let completedAt: Date?
  
  init(
    correctAnswers: Int? = nil,
    totalTime: TimeInterval? = nil,
    completedAt: Date? = nil
  ) {
    self.correctAnswers = correctAnswers
    self.totalTime = totalTime
    self.completedAt = completedAt
  }
}

struct QuizSessionFilterRequest: Codable, Sendable, Equatable {
  let userId: String?
  let category: QuizCategory?
  let mode: QuizMode?
  let startDate: Date?
  let endDate: Date?
  let limit: Int?
  
  init(
    userId: String? = nil,
    category: QuizCategory? = nil,
    mode: QuizMode? = nil,
    startDate: Date? = nil,
    endDate: Date? = nil,
    limit: Int? = nil
  ) {
    self.userId = userId
    self.category = category
    self.mode = mode
    self.startDate = startDate
    self.endDate = endDate
    self.limit = limit
  }
}