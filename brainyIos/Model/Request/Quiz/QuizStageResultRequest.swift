import Foundation

struct CreateQuizStageResultRequest: Codable, Sendable, Equatable {
  let userId: String
  let stageId: String
  let score: Int
  let timeSpent: TimeInterval
  
  init(
    userId: String,
    stageId: String,
    score: Int,
    timeSpent: TimeInterval
  ) {
    self.userId = userId
    self.stageId = stageId
    self.score = score
    self.timeSpent = timeSpent
  }
}

struct QuizStageResultFilterRequest: Codable, Sendable, Equatable {
  let userId: String?
  let stageId: String?
  let isCleared: Bool?
  let minStars: Int?
  let startDate: Date?
  let endDate: Date?
  let limit: Int?
  
  init(
    userId: String? = nil,
    stageId: String? = nil,
    isCleared: Bool? = nil,
    minStars: Int? = nil,
    startDate: Date? = nil,
    endDate: Date? = nil,
    limit: Int? = nil
  ) {
    self.userId = userId
    self.stageId = stageId
    self.isCleared = isCleared
    self.minStars = minStars
    self.startDate = startDate
    self.endDate = endDate
    self.limit = limit
  }
}