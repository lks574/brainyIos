import Foundation

struct CreateQuizResultRequest: Codable, Sendable, Equatable {
  let userId: String
  let questionId: String
  let userAnswer: String
  let isCorrect: Bool
  let timeSpent: TimeInterval
  let category: QuizCategory
  let quizMode: QuizMode
  
  init(
    userId: String,
    questionId: String,
    userAnswer: String,
    isCorrect: Bool,
    timeSpent: TimeInterval,
    category: QuizCategory,
    quizMode: QuizMode
  ) {
    self.userId = userId
    self.questionId = questionId
    self.userAnswer = userAnswer
    self.isCorrect = isCorrect
    self.timeSpent = timeSpent
    self.category = category
    self.quizMode = quizMode
  }
}

struct QuizResultFilterRequest: Codable, Sendable, Equatable {
  let userId: String?
  let category: QuizCategory?
  let quizMode: QuizMode?
  let isCorrect: Bool?
  let startDate: Date?
  let endDate: Date?
  let limit: Int?
  
  init(
    userId: String? = nil,
    category: QuizCategory? = nil,
    quizMode: QuizMode? = nil,
    isCorrect: Bool? = nil,
    startDate: Date? = nil,
    endDate: Date? = nil,
    limit: Int? = nil
  ) {
    self.userId = userId
    self.category = category
    self.quizMode = quizMode
    self.isCorrect = isCorrect
    self.startDate = startDate
    self.endDate = endDate
    self.limit = limit
  }
}