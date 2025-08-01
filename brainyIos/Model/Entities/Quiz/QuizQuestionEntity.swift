import Foundation
import SwiftData

@Model
final class QuizQuestionEntity {
  @Attribute(.unique) var id: String
  var question: String
  var correctAnswer: String
  var options: [String]? // 객관식인 경우
  var category: String
  var difficulty: String
  var type: String
  var audioURL: String? // 음성모드인 경우
  var isCompleted: Bool = false
  
  init(id: String, question: String, correctAnswer: String, category: QuizCategory, difficulty: QuizDifficulty, type: QuizType, options: [String]? = nil, audioURL: String? = nil) {
    self.id = id
    self.question = question
    self.correctAnswer = correctAnswer
    self.category = category.rawValue
    self.difficulty = difficulty.rawValue
    self.type = type.rawValue
    self.options = options
    self.audioURL = audioURL
  }
}
