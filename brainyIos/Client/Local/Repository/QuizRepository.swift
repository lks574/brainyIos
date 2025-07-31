import Foundation
import SwiftData

final class QuizRepository {
  private let dataManager: SwiftDataManager
  private var modelContext: ModelContext { dataManager.modelContext }

  init(dataManager: SwiftDataManager = .shared) {
    self.dataManager = dataManager
  }

  // MARK: - Initial Data Loading
  func loadInitialDataIfNeeded() throws {
    // Check if questions already exist
    let descriptor = FetchDescriptor<QuizQuestionEntity>()
    let existingQuestions = try modelContext.fetch(descriptor)

    guard existingQuestions.isEmpty else {
      print("Quiz questions already exist, skipping initial data load")
      return
    }

    print("Loading initial quiz data...")
    let initialQuestions = QuizDataLoader.loadInitialQuizData()

    for questionRequest in initialQuestions {
      let question = QuizQuestionEntity(
        id: UUID().uuidString,
        question: questionRequest.question,
        correctAnswer: questionRequest.correctAnswer,
        category: questionRequest.category,
        difficulty: questionRequest.difficulty,
        type: questionRequest.type,
        options: questionRequest.options,
        audioURL: questionRequest.audioURL
      )
      modelContext.insert(question)
    }

    try dataManager.save()
    print("Successfully loaded \(initialQuestions.count) quiz questions")
  }

  // 전체 삭제 필요할 때 사용
  func deleteAllData(modelContext: ModelContext) {
    do {
      // 모든 데이터 가져오기
      var descriptor = FetchDescriptor<QuizQuestionEntity>()
      descriptor.fetchLimit = 100 // 한 번에 가져올 데이터 양 제한 (필요에 따라 조절)

      let allData = try modelContext.fetch(descriptor)

      // 데이터 삭제
      for item in allData {
        modelContext.delete(item)
      }

      // 변경 사항 저장
      try modelContext.save()
      print("모든 데이터 삭제 완료")

    } catch {
      print("데이터 삭제 중 오류 발생: \(error)")
    }
  }
}

// MARK: - Quiz Questions
extension QuizRepository {
  func createQuestion(_ req: CreateQuizQuestionRequest) throws -> QuizQuestionDTO {
    let question = QuizQuestionEntity(
      id: UUID().uuidString,
      question: req.question,
      correctAnswer: req.correctAnswer,
      category: req.category,
      difficulty: req.difficulty,
      type: req.type,
      options: req.options,
      audioURL: req.audioURL
    )
    modelContext.insert(question)
    try dataManager.save()
    return QuizQuestionDTO(from: question)
  }

  func fetchQuestions(with filter: QuizQuestionFilterRequest) throws -> [QuizQuestionDTO] {
    var predicate: Predicate<QuizQuestionEntity>?

    // Build predicate based on filter
    if let category = filter.category,
       let difficulty = filter.difficulty,
       let type = filter.type {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.category == category &&
        question.difficulty == difficulty &&
        question.type == type
      }
    } else if let category = filter.category {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.category == category
      }
    } else if let difficulty = filter.difficulty {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.difficulty == difficulty
      }
    } else if let type = filter.type {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.type == type
      }
    }

    var descriptor = FetchDescriptor<QuizQuestionEntity>(predicate: predicate)

    // Apply limit
    if let limit = filter.limit {
      descriptor.fetchLimit = limit
    }

    let questions = try modelContext.fetch(descriptor)
    return questions.map { QuizQuestionDTO(from: $0) }
  }

  func fetchQuestion(by id: String) throws -> QuizQuestionDTO? {
    let predicate = #Predicate<QuizQuestionEntity> { question in
      question.id == id
    }
    let descriptor = FetchDescriptor<QuizQuestionEntity>(predicate: predicate)
    guard let question = try modelContext.fetch(descriptor).first else { return nil }
    return QuizQuestionDTO(from: question)
  }

  func updateQuestion(id: String, with req: QuizQuestionUpdateRequest) throws -> QuizQuestionDTO? {
    let predicate = #Predicate<QuizQuestionEntity> { question in
      question.id == id
    }
    let descriptor = FetchDescriptor<QuizQuestionEntity>(predicate: predicate)
    guard let question = try modelContext.fetch(descriptor).first else { return nil }

    if let questionText = req.question {
      question.question = questionText
    }
    if let correctAnswer = req.correctAnswer {
      question.correctAnswer = correctAnswer
    }
    if let options = req.options {
      question.options = options
    }
    if let category = req.category {
      question.category = category
    }
    if let difficulty = req.difficulty {
      question.difficulty = difficulty
    }
    if let type = req.type {
      question.type = type
    }
    if let audioURL = req.audioURL {
      question.audioURL = audioURL
    }
    if let isCompleted = req.isCompleted {
      question.isCompleted = isCompleted
    }

    try dataManager.save()
    return QuizQuestionDTO(from: question)
  }

  func deleteQuestion(id: String) throws -> Bool {
    let predicate = #Predicate<QuizQuestionEntity> { question in
      question.id == id
    }
    let descriptor = FetchDescriptor<QuizQuestionEntity>(predicate: predicate)
    guard let question = try modelContext.fetch(descriptor).first else { return false }

    modelContext.delete(question)
    try dataManager.save()
    return true
  }
}

// MARK: - Quiz Sessions
extension QuizRepository {
  func createSession(_ req: CreateQuizSessionRequest) throws -> QuizSessionDTO {
    let session = QuizSessionEntity(
      id: UUID().uuidString,
      userId: req.userId,
      category: req.category,
      mode: req.mode,
      totalQuestions: req.totalQuestions
    )
    modelContext.insert(session)
    try dataManager.save()
    return QuizSessionDTO(from: session)
  }

  func fetchSessions(with filter: QuizSessionFilterRequest) throws -> [QuizSessionDTO] {
    var predicate: Predicate<QuizSessionEntity>?

    // Build predicate based on filter
    if let userId = filter.userId,
       let category = filter.category,
       let mode = filter.mode {
      predicate = #Predicate<QuizSessionEntity> { session in
        session.userId == userId &&
        session.category == category &&
        session.mode == mode
      }
    } else if let userId = filter.userId {
      predicate = #Predicate<QuizSessionEntity> { session in
        session.userId == userId
      }
    } else if let category = filter.category {
      predicate = #Predicate<QuizSessionEntity> { session in
        session.category == category
      }
    } else if let mode = filter.mode {
      predicate = #Predicate<QuizSessionEntity> { session in
        session.mode == mode
      }
    }

    var descriptor = FetchDescriptor<QuizSessionEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
    )

    // Apply limit
    if let limit = filter.limit {
      descriptor.fetchLimit = limit
    }

    let sessions = try modelContext.fetch(descriptor)
    return sessions.map { QuizSessionDTO(from: $0) }
  }

  func fetchSession(by id: String) throws -> QuizSessionDTO? {
    let predicate = #Predicate<QuizSessionEntity> { session in
      session.id == id
    }
    let descriptor = FetchDescriptor<QuizSessionEntity>(predicate: predicate)
    guard let session = try modelContext.fetch(descriptor).first else { return nil }
    return QuizSessionDTO(from: session)
  }

  func updateSession(id: String, with req: UpdateQuizSessionRequest) throws -> QuizSessionDTO? {
    let predicate = #Predicate<QuizSessionEntity> { session in
      session.id == id
    }
    let descriptor = FetchDescriptor<QuizSessionEntity>(predicate: predicate)
    guard let session = try modelContext.fetch(descriptor).first else { return nil }

    if let correctAnswers = req.correctAnswers {
      session.correctAnswers = correctAnswers
    }
    if let totalTime = req.totalTime {
      session.totalTime = totalTime
    }
    if let completedAt = req.completedAt {
      session.completedAt = completedAt
    }

    try dataManager.save()
    return QuizSessionDTO(from: session)
  }

  func deleteSession(id: String) throws -> Bool {
    let predicate = #Predicate<QuizSessionEntity> { session in
      session.id == id
    }
    let descriptor = FetchDescriptor<QuizSessionEntity>(predicate: predicate)
    guard let session = try modelContext.fetch(descriptor).first else { return false }

    modelContext.delete(session)
    try dataManager.save()
    return true
  }
}

// MARK: - Quiz Results
extension QuizRepository {
  func createResult(_ req: CreateQuizResultRequest) throws -> QuizResultDTO {
    let result = QuizResultEntity(
      id: UUID().uuidString,
      userId: req.userId,
      questionId: req.questionId,
      userAnswer: req.userAnswer,
      isCorrect: req.isCorrect,
      timeSpent: req.timeSpent,
      category: req.category,
      quizMode: req.quizMode
    )
    modelContext.insert(result)
    try dataManager.save()
    return QuizResultDTO(from: result)
  }

  func fetchResults(with filter: QuizResultFilterRequest) throws -> [QuizResultDTO] {
    var predicate: Predicate<QuizResultEntity>?

    // Build predicate based on filter
    if let userId = filter.userId,
       let category = filter.category,
       let quizMode = filter.quizMode {
      predicate = #Predicate<QuizResultEntity> { result in
        result.userId == userId &&
        result.category == category &&
        result.quizMode == quizMode
      }
    } else if let userId = filter.userId {
      predicate = #Predicate<QuizResultEntity> { result in
        result.userId == userId
      }
    } else if let category = filter.category {
      predicate = #Predicate<QuizResultEntity> { result in
        result.category == category
      }
    } else if let isCorrect = filter.isCorrect {
      predicate = #Predicate<QuizResultEntity> { result in
        result.isCorrect == isCorrect
      }
    }

    var descriptor = FetchDescriptor<QuizResultEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
    )

    // Apply limit
    if let limit = filter.limit {
      descriptor.fetchLimit = limit
    }

    let results = try modelContext.fetch(descriptor)
    return results.map { QuizResultDTO(from: $0) }
  }

  func fetchResult(by id: String) throws -> QuizResultDTO? {
    let predicate = #Predicate<QuizResultEntity> { result in
      result.id == id
    }
    let descriptor = FetchDescriptor<QuizResultEntity>(predicate: predicate)
    guard let result = try modelContext.fetch(descriptor).first else { return nil }
    return QuizResultDTO(from: result)
  }

  func deleteResult(id: String) throws -> Bool {
    let predicate = #Predicate<QuizResultEntity> { result in
      result.id == id
    }
    let descriptor = FetchDescriptor<QuizResultEntity>(predicate: predicate)
    guard let result = try modelContext.fetch(descriptor).first else { return false }

    modelContext.delete(result)
    try dataManager.save()
    return true
  }

  // MARK: - Statistics
  func getUserQuizStats(userId: String) throws -> (totalQuizzes: Int, correctAnswers: Int, accuracy: Double) {
    let predicate = #Predicate<QuizResultEntity> { result in
      result.userId == userId
    }
    let descriptor = FetchDescriptor<QuizResultEntity>(predicate: predicate)
    let results = try modelContext.fetch(descriptor)

    let totalQuizzes = results.count
    let correctAnswers = results.filter { $0.isCorrect }.count
    let accuracy = totalQuizzes > 0 ? Double(correctAnswers) / Double(totalQuizzes) : 0.0

    return (totalQuizzes, correctAnswers, accuracy)
  }

  func getCategoryStats(userId: String, category: QuizCategory) throws -> (totalQuizzes: Int, correctAnswers: Int, accuracy: Double) {
    let predicate = #Predicate<QuizResultEntity> { result in
      result.userId == userId && result.category == category
    }
    let descriptor = FetchDescriptor<QuizResultEntity>(predicate: predicate)
    let results = try modelContext.fetch(descriptor)

    let totalQuizzes = results.count
    let correctAnswers = results.filter { $0.isCorrect }.count
    let accuracy = totalQuizzes > 0 ? Double(correctAnswers) / Double(totalQuizzes) : 0.0

    return (totalQuizzes, correctAnswers, accuracy)
  }
}
