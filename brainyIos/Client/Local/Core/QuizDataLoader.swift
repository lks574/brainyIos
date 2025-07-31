import Foundation

struct QuizDataLoader {
  static func loadInitialQuizData() -> [CreateQuizQuestionRequest] {
    guard let url = Bundle.main.url(forResource: "quiz_data", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
      print("Failed to load quiz_data.json")
      return []
    }

    do {
      let quizData = try JSONDecoder().decode(QuizDataResponse.self, from: data)
      return quizData.questions.map { question in
        CreateQuizQuestionRequest(
          question: question.question,
          correctAnswer: question.correctAnswer,
          category: QuizCategory(rawValue: question.category) ?? .general,
          difficulty: QuizDifficulty(rawValue: question.difficulty) ?? .easy,
          type: QuizType(rawValue: question.type) ?? .multipleChoice,
          options: question.options,
          audioURL: question.audioURL
        )
      }
    } catch {
      print("Failed to decode quiz data: \(error)")
      return []
    }
  }
}

// MARK: - JSON Response Models
private struct QuizDataResponse: Codable {
  let questions: [QuizQuestionResponse]
}

private struct QuizQuestionResponse: Codable {
  let id: String
  let question: String
  let correctAnswer: String
  let options: [String]?
  let category: String
  let difficulty: String
  let type: String
  let audioURL: String?
}
