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
    // Check if stages already exist
    let stageDescriptor = FetchDescriptor<QuizStageEntity>()
    let existingStages = try modelContext.fetch(stageDescriptor)

    guard existingStages.isEmpty else {
      print("Quiz stages already exist, skipping initial data load")
      return
    }

    print("Loading initial quiz data...")
    let initialQuestions = QuizDataLoader.loadInitialQuizData()
    
    // Create stages and questions
    try createInitialStagesAndQuestions(from: initialQuestions)
    
    try dataManager.save()
    print("Successfully loaded initial quiz data with stages")
  }
  
  private func createInitialStagesAndQuestions(from questions: [CreateQuizQuestionRequest]) throws {
    // Group questions by category and difficulty
    let groupedQuestions = Dictionary(grouping: questions) { question in
      "\(question.category.rawValue)_\(question.difficulty.rawValue)"
    }
    
    for (key, categoryQuestions) in groupedQuestions {
      let components = key.split(separator: "_")
      guard components.count == 2,
            let category = QuizCategory(rawValue: String(components[0])),
            let difficulty = QuizDifficulty(rawValue: String(components[1])) else {
        continue
      }
      
      // Create stages (10 questions per stage)
      let questionsPerStage = 10
      let stageCount = (categoryQuestions.count + questionsPerStage - 1) / questionsPerStage
      
      for stageIndex in 0..<stageCount {
        let stageNumber = stageIndex + 1
        let stageId = "\(category.rawValue)_stage_\(stageNumber)"
        
        let stage = QuizStageEntity(
          id: stageId,
          stageNumber: stageNumber,
          category: category,
          difficulty: difficulty,
          title: "\(category.displayName) \(stageNumber)단계"
        )
        modelContext.insert(stage)
        
        // Add questions to this stage
        let startIndex = stageIndex * questionsPerStage
        let endIndex = min(startIndex + questionsPerStage, categoryQuestions.count)
        
        for (questionIndex, questionRequest) in categoryQuestions[startIndex..<endIndex].enumerated() {
          let question = QuizQuestionEntity(
            id: UUID().uuidString,
            question: questionRequest.question,
            correctAnswer: questionRequest.correctAnswer,
            category: questionRequest.category,
            difficulty: questionRequest.difficulty,
            type: questionRequest.type,
            options: questionRequest.options,
            audioURL: questionRequest.audioURL,
            stageId: stageId,
            orderInStage: questionIndex + 1
          )
          modelContext.insert(question)
        }
      }
    }
  }

  // 전체 삭제 필요할 때 사용
  func deleteAllData() throws {
    // Delete all entities
    let stageDescriptor = FetchDescriptor<QuizStageEntity>()
    let stages = try modelContext.fetch(stageDescriptor)
    stages.forEach { modelContext.delete($0) }
    
    let questionDescriptor = FetchDescriptor<QuizQuestionEntity>()
    let questions = try modelContext.fetch(questionDescriptor)
    questions.forEach { modelContext.delete($0) }
    
    let resultDescriptor = FetchDescriptor<QuizStageResultEntity>()
    let results = try modelContext.fetch(resultDescriptor)
    results.forEach { modelContext.delete($0) }
    
    try dataManager.save()
    print("모든 데이터 삭제 완료")
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
        question.category == category.rawValue &&
        question.difficulty == difficulty.rawValue &&
        question.type == type.rawValue
      }
    } else if let category = filter.category {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.category == category.rawValue
      }
    } else if let difficulty = filter.difficulty {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.difficulty == difficulty.rawValue
      }
    } else if let type = filter.type {
      predicate = #Predicate<QuizQuestionEntity> { question in
        question.type == type.rawValue
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
  
  func fetchQuestionsForStage(stageId: String) throws -> [QuizQuestionDTO] {
    let predicate = #Predicate<QuizQuestionEntity> { question in
      question.stageId == stageId
    }
    let descriptor = FetchDescriptor<QuizQuestionEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.orderInStage)]
    )
    
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
      question.category = category.rawValue
    }
    if let difficulty = req.difficulty {
      question.difficulty = difficulty.rawValue
    }
    if let type = req.type {
      question.type = type.rawValue
    }
    if let audioURL = req.audioURL {
      question.audioURL = audioURL
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

// MARK: - Quiz Stages
extension QuizRepository {
  func fetchStages(category: QuizCategory? = nil, difficulty: QuizDifficulty? = nil) throws -> [QuizStageDTO] {
    var predicate: Predicate<QuizStageEntity>?
    
    if let category = category, let difficulty = difficulty {
      predicate = #Predicate<QuizStageEntity> { stage in
        stage.category == category.rawValue && stage.difficulty == difficulty.rawValue
      }
    } else if let category = category {
      predicate = #Predicate<QuizStageEntity> { stage in
        stage.category == category.rawValue
      }
    } else if let difficulty = difficulty {
      predicate = #Predicate<QuizStageEntity> { stage in
        stage.difficulty == difficulty.rawValue
      }
    }
    
    let descriptor = FetchDescriptor<QuizStageEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.stageNumber)]
    )
    
    let stages = try modelContext.fetch(descriptor)
    return stages.map { QuizStageDTO(from: $0) }
  }
  
  func fetchStage(by id: String) throws -> QuizStageDTO? {
    let predicate = #Predicate<QuizStageEntity> { stage in
      stage.id == id
    }
    let descriptor = FetchDescriptor<QuizStageEntity>(predicate: predicate)
    guard let stage = try modelContext.fetch(descriptor).first else { return nil }
    return QuizStageDTO(from: stage)
  }
  
  func fetchStagesByCategory(_ category: QuizCategory) throws -> [QuizStageDTO] {
    let predicate = #Predicate<QuizStageEntity> { stage in
      stage.category == category.rawValue
    }
    let descriptor = FetchDescriptor<QuizStageEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.stageNumber)]
    )
    
    let stages = try modelContext.fetch(descriptor)
    return stages.map { QuizStageDTO(from: $0) }
  }
}

// MARK: - Quiz Stage Results
extension QuizRepository {
  func createStageResult(userId: String, stageId: String, score: Int, timeSpent: TimeInterval) throws -> QuizStageResultDTO {
    let result = QuizStageResultEntity(
      id: UUID().uuidString,
      userId: userId,
      stageId: stageId,
      score: score,
      timeSpent: timeSpent
    )
    modelContext.insert(result)
    try dataManager.save()
    return QuizStageResultDTO(from: result)
  }
  
  func fetchStageResults(userId: String? = nil, stageId: String? = nil, limit: Int? = nil) throws -> [QuizStageResultDTO] {
    var predicate: Predicate<QuizStageResultEntity>?
    
    if let userId = userId, let stageId = stageId {
      predicate = #Predicate<QuizStageResultEntity> { result in
        result.userId == userId && result.stageId == stageId
      }
    } else if let userId = userId {
      predicate = #Predicate<QuizStageResultEntity> { result in
        result.userId == userId
      }
    } else if let stageId = stageId {
      predicate = #Predicate<QuizStageResultEntity> { result in
        result.stageId == stageId
      }
    }
    
    var descriptor = FetchDescriptor<QuizStageResultEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
    )
    
    if let limit = limit {
      descriptor.fetchLimit = limit
    }
    
    let results = try modelContext.fetch(descriptor)
    return results.map { QuizStageResultDTO(from: $0) }
  }
  
  func fetchBestStageResult(userId: String, stageId: String) throws -> QuizStageResultDTO? {
    let predicate = #Predicate<QuizStageResultEntity> { result in
      result.userId == userId && result.stageId == stageId
    }
    var descriptor = FetchDescriptor<QuizStageResultEntity>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.score, order: .reverse)]
    )
    descriptor.fetchLimit = 1
    
    guard let result = try modelContext.fetch(descriptor).first else { return nil }
    return QuizStageResultDTO(from: result)
  }
  
  func isStageUnlocked(userId: String, stageId: String) throws -> Bool {
    // First stage is always unlocked
    guard let stage = try fetchStage(by: stageId) else { return false }
    
    if stage.stageNumber == 1 {
      return true
    }
    
    // Check if previous stage is cleared
    let previousStageNumber = stage.stageNumber - 1
    let previousStageId = "\(stage.category.rawValue)_stage_\(previousStageNumber)"
    
    let predicate = #Predicate<QuizStageResultEntity> { result in
      result.userId == userId && result.stageId == previousStageId && result.isCleared == true
    }
    var descriptor = FetchDescriptor<QuizStageResultEntity>(predicate: predicate)
    descriptor.fetchLimit = 1

    return !(try modelContext.fetch(descriptor).isEmpty)
  }
  
  func deleteStageResult(id: String) throws -> Bool {
    let predicate = #Predicate<QuizStageResultEntity> { result in
      result.id == id
    }
    let descriptor = FetchDescriptor<QuizStageResultEntity>(predicate: predicate)
    guard let result = try modelContext.fetch(descriptor).first else { return false }
    
    modelContext.delete(result)
    try dataManager.save()
    return true
  }

  // MARK: - Statistics
  func getUserStageStats(userId: String) throws -> (totalStagesCompleted: Int, totalStars: Int, overallAccuracy: Double) {
    let predicate = #Predicate<QuizStageResultEntity> { result in
      result.userId == userId
    }
    let descriptor = FetchDescriptor<QuizStageResultEntity>(predicate: predicate)
    let results = try modelContext.fetch(descriptor)

    let totalStagesCompleted = results.filter { $0.isCleared }.count
    let totalStars = results.reduce(0) { $0 + $1.stars }
    let totalScore = results.reduce(0) { $0 + $1.score }
    let totalQuestions = results.count * 10
    let overallAccuracy = totalQuestions > 0 ? Double(totalScore) / Double(totalQuestions) : 0.0

    return (totalStagesCompleted, totalStars, overallAccuracy)
  }

  func getCategoryStageStats(userId: String, category: QuizCategory) throws -> (completedStages: Int, totalStars: Int, unlockedStage: Int) {
    // Get all stages for this category
    let stages = try fetchStagesByCategory(category)
    
    // Get user's results for this category
    let results = try fetchStageResults(userId: userId)
    let categoryResults = results.filter { result in
      stages.contains { $0.id == result.stageId }
    }
    
    let completedStages = categoryResults.filter { $0.isCleared }.count
    let totalStars = categoryResults.reduce(0) { $0 + $1.stars }
    let unlockedStage = completedStages + 1
    
    return (completedStages, totalStars, unlockedStage)
  }
}
