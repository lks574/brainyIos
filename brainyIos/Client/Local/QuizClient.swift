import ComposableArchitecture
import Foundation

@DependencyClient
struct QuizClient {
  // MARK: - Quiz Questions
  var createQuestion: @Sendable (CreateQuizQuestionRequest) async throws -> QuizQuestionDTO
  var fetchQuestions: @Sendable (QuizQuestionFilterRequest) async throws -> [QuizQuestionDTO]
  var fetchQuestionsForStage: @Sendable (String) async throws -> [QuizQuestionDTO]
  var fetchQuestion: @Sendable (String) async throws -> QuizQuestionDTO?
  var updateQuestion: @Sendable (String, QuizQuestionUpdateRequest) async throws -> QuizQuestionDTO?
  var deleteQuestion: @Sendable (String) async throws -> Bool
  
  // MARK: - Quiz Stages
  var fetchStages: @Sendable (QuizCategory?, QuizDifficulty?) async throws -> [QuizStageDTO]
  var fetchStage: @Sendable (String) async throws -> QuizStageDTO?
  var fetchStagesByCategory: @Sendable (QuizCategory) async throws -> [QuizStageDTO]
  
  // MARK: - Quiz Stage Results
  var createStageResult: @Sendable (String, String, Int, TimeInterval) async throws -> QuizStageResultDTO
  var fetchStageResults: @Sendable (String?, String?, Int?) async throws -> [QuizStageResultDTO]
  var fetchBestStageResult: @Sendable (String, String) async throws -> QuizStageResultDTO?
  var isStageUnlocked: @Sendable (String, String) async throws -> Bool
  var deleteStageResult: @Sendable (String) async throws -> Bool
  
  // MARK: - Statistics
  var getUserStageStats: @Sendable (String) async throws -> (totalStagesCompleted: Int, totalStars: Int, overallAccuracy: Double)
  var getCategoryStageStats: @Sendable (String, QuizCategory) async throws -> (completedStages: Int, totalStars: Int, unlockedStage: Int)
  
  // MARK: - Initial Data Loading
  var loadInitialDataIfNeeded: @Sendable () async throws -> Void
  var deleteAllData: @Sendable () async throws -> Void
}

extension QuizClient: DependencyKey {
  static let liveValue: QuizClient = {
    let repository = QuizRepository()
    return QuizClient(
      // MARK: - Quiz Questions
      createQuestion: { req in
        try repository.createQuestion(req)
      },
      fetchQuestions: { filter in
        try repository.fetchQuestions(with: filter)
      },
      fetchQuestionsForStage: { stageId in
        try repository.fetchQuestionsForStage(stageId: stageId)
      },
      fetchQuestion: { id in
        try repository.fetchQuestion(by: id)
      },
      updateQuestion: { id, req in
        try repository.updateQuestion(id: id, with: req)
      },
      deleteQuestion: { id in
        try repository.deleteQuestion(id: id)
      },
      
      // MARK: - Quiz Stages
      fetchStages: { category, difficulty in
        try repository.fetchStages(category: category, difficulty: difficulty)
      },
      fetchStage: { id in
        try repository.fetchStage(by: id)
      },
      fetchStagesByCategory: { category in
        try repository.fetchStagesByCategory(category)
      },
      
      // MARK: - Quiz Stage Results
      createStageResult: { userId, stageId, score, timeSpent in
        try repository.createStageResult(userId: userId, stageId: stageId, score: score, timeSpent: timeSpent)
      },
      fetchStageResults: { userId, stageId, limit in
        try repository.fetchStageResults(userId: userId, stageId: stageId, limit: limit)
      },
      fetchBestStageResult: { userId, stageId in
        try repository.fetchBestStageResult(userId: userId, stageId: stageId)
      },
      isStageUnlocked: { userId, stageId in
        try repository.isStageUnlocked(userId: userId, stageId: stageId)
      },
      deleteStageResult: { id in
        try repository.deleteStageResult(id: id)
      },
      
      // MARK: - Statistics
      getUserStageStats: { userId in
        try repository.getUserStageStats(userId: userId)
      },
      getCategoryStageStats: { userId, category in
        try repository.getCategoryStageStats(userId: userId, category: category)
      },
      
      // MARK: - Initial Data Loading
      loadInitialDataIfNeeded: {
        try repository.loadInitialDataIfNeeded()
      },
      deleteAllData: {
        try repository.deleteAllData()
      }
    )
  }()
}

extension DependencyValues {
  var quizClient: QuizClient {
    get { self[QuizClient.self] }
    set { self[QuizClient.self] = newValue }
  }
}

// MARK: - Test Implementation
extension QuizClient {
  static let testValue = QuizClient(
    // MARK: - Quiz Questions
    createQuestion: { _ in .mock },
    fetchQuestions: { _ in .mockList },
    fetchQuestionsForStage: { _ in .mockList },
    fetchQuestion: { _ in .mock },
    updateQuestion: { _, _ in .mock },
    deleteQuestion: { _ in true },
    
    // MARK: - Quiz Stages
    fetchStages: { _, _ in .mockList },
    fetchStage: { _ in .mock },
    fetchStagesByCategory: { _ in .mockList },
    
    // MARK: - Quiz Stage Results
    createStageResult: { _, _, _, _ in .mock },
    fetchStageResults: { _, _, _ in .mockList },
    fetchBestStageResult: { _, _ in .mock },
    isStageUnlocked: { _, _ in true },
    deleteStageResult: { _ in true },
    
    // MARK: - Statistics
    getUserStageStats: { _ in (totalStagesCompleted: 10, totalStars: 25, overallAccuracy: 0.8) },
    getCategoryStageStats: { _, _ in (completedStages: 5, totalStars: 12, unlockedStage: 6) },
    
    // MARK: - Initial Data Loading
    loadInitialDataIfNeeded: { },
    deleteAllData: { }
  )
  
  static let previewValue = testValue
}

// MARK: - Convenience Methods
extension QuizClient {
  /// Get all stages for a specific category with unlock status for a user
  func getStagesWithUnlockStatus(for category: QuizCategory, userId: String) async throws -> [(stage: QuizStageDTO, isUnlocked: Bool)] {
    let stages = try await fetchStagesByCategory(category)
    var result: [(stage: QuizStageDTO, isUnlocked: Bool)] = []
    
    for stage in stages {
      let isUnlocked = try await isStageUnlocked(userId, stage.id)
      result.append((stage: stage, isUnlocked: isUnlocked))
    }
    
    return result
  }
  
  /// Get user's progress for a specific category
  func getCategoryProgress(for category: QuizCategory, userId: String) async throws -> CategoryProgress {
    let stats = try await getCategoryStageStats(userId, category)
    let stages = try await fetchStagesByCategory(category)
    
    return CategoryProgress(
      category: category,
      totalStages: stages.count,
      completedStages: stats.completedStages,
      totalStars: stats.totalStars,
      unlockedStage: stats.unlockedStage,
      maxStars: stages.count * 3 // 3 stars per stage
    )
  }
  
  /// Check if user can play a specific stage
  func canPlayStage(_ stageId: String, userId: String) async throws -> Bool {
    return try await isStageUnlocked(userId, stageId)
  }
  
  /// Get user's best performance for a stage
  func getStagePerformance(stageId: String, userId: String) async throws -> StagePerformance? {
    guard let bestResult = try await fetchBestStageResult(userId, stageId) else {
      return nil
    }
    
    return StagePerformance(
      stageId: stageId,
      bestScore: bestResult.score,
      bestStars: bestResult.stars,
      bestAccuracy: bestResult.accuracy,
      bestTime: bestResult.timeSpent,
      isCleared: bestResult.isCleared,
      completedAt: bestResult.completedAt
    )
  }
}

// MARK: - Supporting Types
struct CategoryProgress: Equatable, Sendable {
  let category: QuizCategory
  let totalStages: Int
  let completedStages: Int
  let totalStars: Int
  let unlockedStage: Int
  let maxStars: Int
  
  var progressPercentage: Double {
    guard totalStages > 0 else { return 0 }
    return Double(completedStages) / Double(totalStages)
  }
  
  var starPercentage: Double {
    guard maxStars > 0 else { return 0 }
    return Double(totalStars) / Double(maxStars)
  }
}

struct StagePerformance: Equatable, Sendable {
  let stageId: String
  let bestScore: Int
  let bestStars: Int
  let bestAccuracy: Double
  let bestTime: TimeInterval
  let isCleared: Bool
  let completedAt: Date
  
  var accuracyPercentage: String {
    return String(format: "%.0f%%", bestAccuracy * 100)
  }
  
  var starsDisplay: String {
    return String(repeating: "⭐", count: bestStars)
  }
}
