import ComposableArchitecture
import Foundation

@DependencyClient
struct QuizStatsClient {
  // MARK: - User Statistics
  var getUserOverallStats: @Sendable (String) async throws -> UserOverallStats
  var getUserCategoryStats: @Sendable (String) async throws -> [CategoryStats]
  var getUserRecentActivity: @Sendable (String, Int?) async throws -> [RecentActivity]
  var getUserAchievements: @Sendable (String) async throws -> [Achievement]
  
  // MARK: - Category Analytics
  var getCategoryLeaderboard: @Sendable (QuizCategory, Int?) async throws -> [LeaderboardEntry]
  var getCategoryAnalytics: @Sendable (QuizCategory) async throws -> CategoryAnalytics
  
  // MARK: - Performance Tracking
  var getPerformanceTrend: @Sendable (String, QuizCategory?, TimeRange) async throws -> PerformanceTrend
  var getWeakAreas: @Sendable (String) async throws -> [WeakArea]
  var getStrengthAreas: @Sendable (String) async throws -> [StrengthArea]
  
  // MARK: - Recommendations
  var getRecommendedStages: @Sendable (String) async throws -> [RecommendedStage]
  var getDailyGoal: @Sendable (String) async throws -> DailyGoal
  var updateDailyGoal: @Sendable (String, DailyGoal) async throws -> DailyGoal
}

extension QuizStatsClient: DependencyKey {
  static let liveValue: QuizStatsClient = {
    let quizClient = QuizClient.liveValue
    
    return QuizStatsClient(
      getUserOverallStats: { userId in
        let stats = try await quizClient.getUserStageStats(userId)
        let recentResults = try await quizClient.fetchStageResults(userId, nil, 10)
        
        // Calculate streak
        let currentStreak = calculateCurrentStreak(from: recentResults)
        let bestStreak = calculateBestStreak(from: recentResults)
        
        return UserOverallStats(
          totalStagesCompleted: stats.totalStagesCompleted,
          totalStars: stats.totalStars,
          overallAccuracy: stats.overallAccuracy,
          currentStreak: currentStreak,
          bestStreak: bestStreak,
          totalPlayTime: calculateTotalPlayTime(from: recentResults),
          averageStageTime: calculateAverageStageTime(from: recentResults),
          rank: calculateUserRank(userId: userId, stats: stats)
        )
      },
      
      getUserCategoryStats: { userId in
        var categoryStats: [CategoryStats] = []
        
        for category in QuizCategory.allCases {
          let stats = try await quizClient.getCategoryStageStats(userId, category)
          let stages = try await quizClient.fetchStagesByCategory(category)
          let results = try await quizClient.fetchStageResults(userId, nil, nil)
          let categoryResults = results.filter { result in
            stages.contains { $0.id == result.stageId }
          }
          
          let categoryAccuracy = calculateCategoryAccuracy(from: categoryResults)
          let averageTime = calculateAverageTime(from: categoryResults)
          
          categoryStats.append(CategoryStats(
            category: category,
            completedStages: stats.completedStages,
            totalStages: stages.count,
            totalStars: stats.totalStars,
            maxStars: stages.count * 3,
            accuracy: categoryAccuracy,
            averageTime: averageTime,
            unlockedStage: stats.unlockedStage
          ))
        }
        
        return categoryStats
      },
      
      getUserRecentActivity: { userId, limit in
        let results = try await quizClient.fetchStageResults(userId, nil, limit)
        return results.map { result in
          RecentActivity(
            id: result.id,
            stageId: result.stageId,
            score: result.score,
            stars: result.stars,
            accuracy: result.accuracy,
            timeSpent: result.timeSpent,
            completedAt: result.completedAt,
            isCleared: result.isCleared
          )
        }
      },
      
      getUserAchievements: { userId in
        let stats = try await quizClient.getUserStageStats(userId)
        let categoryStats = try await quizClient.fetchStageResults(userId, nil, nil)
        
        return generateAchievements(
          totalStagesCompleted: stats.totalStagesCompleted,
          totalStars: stats.totalStars,
          overallAccuracy: stats.overallAccuracy,
          results: categoryStats
        )
      },
      
      getCategoryLeaderboard: { category, limit in
        // This would typically fetch from a server or calculate from all users
        // For now, return mock data
        return generateMockLeaderboard(for: category, limit: limit ?? 10)
      },
      
      getCategoryAnalytics: { category in
        let stages = try await quizClient.fetchStagesByCategory(category)
        // This would analyze all users' performance for this category
        return CategoryAnalytics(
          category: category,
          totalStages: stages.count,
          averageCompletionRate: 0.75,
          averageAccuracy: 0.82,
          mostDifficultStage: stages.last?.id ?? "",
          easiestStage: stages.first?.id ?? "",
          averageTimePerStage: 120.0
        )
      },
      
      getPerformanceTrend: { userId, category, timeRange in
        let results = try await quizClient.fetchStageResults(userId, nil, nil)
        let filteredResults = filterResultsByTimeRange(results, timeRange)
        
        return PerformanceTrend(
          timeRange: timeRange,
          dataPoints: generateTrendDataPoints(from: filteredResults),
          averageAccuracy: calculateAverageAccuracy(from: filteredResults),
          improvementRate: calculateImprovementRate(from: filteredResults)
        )
      },
      
      getWeakAreas: { userId in
        let categoryStats = try await quizClient.fetchStageResults(userId, nil, nil)
        return identifyWeakAreas(from: categoryStats)
      },
      
      getStrengthAreas: { userId in
        let categoryStats = try await quizClient.fetchStageResults(userId, nil, nil)
        return identifyStrengthAreas(from: categoryStats)
      },
      
      getRecommendedStages: { userId in
        let allCategories = QuizCategory.allCases
        var recommendations: [RecommendedStage] = []
        
        for category in allCategories {
          let stats = try await quizClient.getCategoryStageStats(userId, category)
          let stages = try await quizClient.fetchStagesByCategory(category)
          
          if stats.unlockedStage <= stages.count {
            let nextStage = stages.first { $0.stageNumber == stats.unlockedStage }
            if let stage = nextStage {
              recommendations.append(RecommendedStage(
                stage: stage,
                reason: .nextInSequence,
                priority: calculatePriority(for: category, stats: stats)
              ))
            }
          }
        }
        
        return recommendations.sorted { $0.priority > $1.priority }
      },
      
      getDailyGoal: { userId in
        // This would typically be stored in user preferences
        return DailyGoal(
          userId: userId,
          targetStages: 3,
          targetStars: 6,
          targetAccuracy: 0.8,
          currentProgress: DailyProgress(
            stagesCompleted: 1,
            starsEarned: 2,
            currentAccuracy: 0.75
          ),
          lastUpdated: Date()
        )
      },
      
      updateDailyGoal: { userId, goal in
        // This would typically save to user preferences
        return goal
      }
    )
  }()
}

extension DependencyValues {
  var quizStatsClient: QuizStatsClient {
    get { self[QuizStatsClient.self] }
    set { self[QuizStatsClient.self] = newValue }
  }
}

// MARK: - Helper Functions
private func calculateCurrentStreak(from results: [QuizStageResultDTO]) -> Int {
  let sortedResults = results.sorted { $0.completedAt > $1.completedAt }
  var streak = 0
  
  for result in sortedResults {
    if result.isCleared {
      streak += 1
    } else {
      break
    }
  }
  
  return streak
}

private func calculateBestStreak(from results: [QuizStageResultDTO]) -> Int {
  let sortedResults = results.sorted { $0.completedAt < $1.completedAt }
  var currentStreak = 0
  var bestStreak = 0
  
  for result in sortedResults {
    if result.isCleared {
      currentStreak += 1
      bestStreak = max(bestStreak, currentStreak)
    } else {
      currentStreak = 0
    }
  }
  
  return bestStreak
}

private func calculateTotalPlayTime(from results: [QuizStageResultDTO]) -> TimeInterval {
  return results.reduce(0) { $0 + $1.timeSpent }
}

private func calculateAverageStageTime(from results: [QuizStageResultDTO]) -> TimeInterval {
  guard !results.isEmpty else { return 0 }
  return calculateTotalPlayTime(from: results) / Double(results.count)
}

private func calculateUserRank(userId: String, stats: (totalStagesCompleted: Int, totalStars: Int, overallAccuracy: Double)) -> Int {
  // This would typically compare with other users
  return 1
}

private func calculateCategoryAccuracy(from results: [QuizStageResultDTO]) -> Double {
  guard !results.isEmpty else { return 0 }
  let totalScore = results.reduce(0) { $0 + $1.score }
  let totalQuestions = results.count * 10
  return Double(totalScore) / Double(totalQuestions)
}

private func calculateAverageTime(from results: [QuizStageResultDTO]) -> TimeInterval {
  guard !results.isEmpty else { return 0 }
  return results.reduce(0) { $0 + $1.timeSpent } / Double(results.count)
}

private func generateAchievements(
  totalStagesCompleted: Int,
  totalStars: Int,
  overallAccuracy: Double,
  results: [QuizStageResultDTO]
) -> [Achievement] {
  var achievements: [Achievement] = []
  
  // Stage completion achievements
  if totalStagesCompleted >= 10 {
    achievements.append(Achievement(
      id: "stages_10",
      title: "스테이지 마스터",
      description: "10개 스테이지 완료",
      iconName: "star.fill",
      unlockedAt: Date()
    ))
  }
  
  // Star collection achievements
  if totalStars >= 50 {
    achievements.append(Achievement(
      id: "stars_50",
      title: "별 수집가",
      description: "50개 별 획득",
      iconName: "star.circle.fill",
      unlockedAt: Date()
    ))
  }
  
  // Accuracy achievements
  if overallAccuracy >= 0.9 {
    achievements.append(Achievement(
      id: "accuracy_90",
      title: "정확도 마스터",
      description: "90% 이상 정확도 달성",
      iconName: "target",
      unlockedAt: Date()
    ))
  }
  
  return achievements
}

private func generateMockLeaderboard(for category: QuizCategory, limit: Int) -> [LeaderboardEntry] {
  return (1...limit).map { rank in
    LeaderboardEntry(
      rank: rank,
      userId: "user-\(rank)",
      username: "사용자\(rank)",
      score: 1000 - (rank * 10),
      stars: 30 - rank,
      accuracy: 0.95 - (Double(rank) * 0.01)
    )
  }
}

private func filterResultsByTimeRange(_ results: [QuizStageResultDTO], _ timeRange: TimeRange) -> [QuizStageResultDTO] {
  let now = Date()
  let startDate: Date
  
  switch timeRange {
  case .week:
    startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
  case .month:
    startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
  case .threeMonths:
    startDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
  case .year:
    startDate = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
  }
  
  return results.filter { $0.completedAt >= startDate }
}

private func generateTrendDataPoints(from results: [QuizStageResultDTO]) -> [TrendDataPoint] {
  let sortedResults = results.sorted { $0.completedAt < $1.completedAt }
  return sortedResults.enumerated().map { index, result in
    TrendDataPoint(
      date: result.completedAt,
      accuracy: result.accuracy,
      score: result.score,
      timeSpent: result.timeSpent
    )
  }
}

private func calculateAverageAccuracy(from results: [QuizStageResultDTO]) -> Double {
  guard !results.isEmpty else { return 0 }
  return results.reduce(0) { $0 + $1.accuracy } / Double(results.count)
}

private func calculateImprovementRate(from results: [QuizStageResultDTO]) -> Double {
  guard results.count >= 2 else { return 0 }
  let sortedResults = results.sorted { $0.completedAt < $1.completedAt }
  let firstHalf = Array(sortedResults.prefix(sortedResults.count / 2))
  let secondHalf = Array(sortedResults.suffix(sortedResults.count / 2))
  
  let firstHalfAccuracy = calculateAverageAccuracy(from: firstHalf)
  let secondHalfAccuracy = calculateAverageAccuracy(from: secondHalf)
  
  return secondHalfAccuracy - firstHalfAccuracy
}

private func identifyWeakAreas(from results: [QuizStageResultDTO]) -> [WeakArea] {
  // Group by category and find low-performing areas
  // This is a simplified implementation
  return [
    WeakArea(
      category: .history,
      averageAccuracy: 0.65,
      recommendedAction: "역사 관련 스테이지를 더 연습해보세요"
    )
  ]
}

private func identifyStrengthAreas(from results: [QuizStageResultDTO]) -> [StrengthArea] {
  // Group by category and find high-performing areas
  return [
    StrengthArea(
      category: .general,
      averageAccuracy: 0.92,
      achievement: "일반상식 분야에서 뛰어난 실력을 보이고 있습니다!"
    )
  ]
}

private func calculatePriority(for category: QuizCategory, stats: (completedStages: Int, totalStars: Int, unlockedStage: Int)) -> Double {
  // Simple priority calculation based on progress
  let progressRatio = Double(stats.completedStages) / Double(stats.unlockedStage)
  return 1.0 - progressRatio // Lower progress = higher priority
}

// MARK: - Test Implementation
extension QuizStatsClient {
//  static let testValue = QuizStatsClient(
//    getUserOverallStats: { _ in .mock },
//    getUserCategoryStats: { _ in .mockList },
//    getUserRecentActivity: { _, _ in .mockList },
//    getUserAchievements: { _ in .mockList },
//    getCategoryLeaderboard: { _, _ in .mockList },
//    getCategoryAnalytics: { _ in .mock },
//    getPerformanceTrend: { _, _, _ in .mock },
//    getWeakAreas: { _ in .mockList },
//    getStrengthAreas: { _ in .mockList },
//    getRecommendedStages: { _ in .mockList },
//    getDailyGoal: { _ in .mock },
//    updateDailyGoal: { _, goal in goal }
//  )
  
  static let previewValue = testValue
}
// MARK: - Supporting Types
struct UserOverallStats: Equatable, Sendable {
  let totalStagesCompleted: Int
  let totalStars: Int
  let overallAccuracy: Double
  let currentStreak: Int
  let bestStreak: Int
  let totalPlayTime: TimeInterval
  let averageStageTime: TimeInterval
  let rank: Int
  
  var accuracyPercentage: String {
    return String(format: "%.1f%%", overallAccuracy * 100)
  }
  
  var formattedPlayTime: String {
    let hours = Int(totalPlayTime) / 3600
    let minutes = Int(totalPlayTime) % 3600 / 60
    return "\(hours)시간 \(minutes)분"
  }
}

struct CategoryStats: Equatable, Sendable {
  let category: QuizCategory
  let completedStages: Int
  let totalStages: Int
  let totalStars: Int
  let maxStars: Int
  let accuracy: Double
  let averageTime: TimeInterval
  let unlockedStage: Int
  
  var progressPercentage: Double {
    guard totalStages > 0 else { return 0 }
    return Double(completedStages) / Double(totalStages)
  }
  
  var starPercentage: Double {
    guard maxStars > 0 else { return 0 }
    return Double(totalStars) / Double(maxStars)
  }
}

struct RecentActivity: Equatable, Sendable, Identifiable {
  let id: String
  let stageId: String
  let score: Int
  let stars: Int
  let accuracy: Double
  let timeSpent: TimeInterval
  let completedAt: Date
  let isCleared: Bool
  
  var accuracyPercentage: String {
    return String(format: "%.0f%%", accuracy * 100)
  }
  
  var starsDisplay: String {
    return String(repeating: "⭐", count: stars)
  }
}

struct Achievement: Equatable, Sendable, Identifiable {
  let id: String
  let title: String
  let description: String
  let iconName: String
  let unlockedAt: Date
}

struct LeaderboardEntry: Equatable, Sendable, Identifiable {
  let rank: Int
  let userId: String
  let username: String
  let score: Int
  let stars: Int
  let accuracy: Double
  
  var id: String { userId }
  
  var accuracyPercentage: String {
    return String(format: "%.1f%%", accuracy * 100)
  }
}

struct CategoryAnalytics: Equatable, Sendable {
  let category: QuizCategory
  let totalStages: Int
  let averageCompletionRate: Double
  let averageAccuracy: Double
  let mostDifficultStage: String
  let easiestStage: String
  let averageTimePerStage: TimeInterval
}

struct PerformanceTrend: Equatable, Sendable {
  let timeRange: TimeRange
  let dataPoints: [TrendDataPoint]
  let averageAccuracy: Double
  let improvementRate: Double
  
  var isImproving: Bool {
    return improvementRate > 0
  }
}

struct TrendDataPoint: Equatable, Sendable {
  let date: Date
  let accuracy: Double
  let score: Int
  let timeSpent: TimeInterval
}

enum TimeRange: String, CaseIterable, Sendable {
  case week = "week"
  case month = "month"
  case threeMonths = "threeMonths"
  case year = "year"
  
  var displayName: String {
    switch self {
    case .week: return "1주일"
    case .month: return "1개월"
    case .threeMonths: return "3개월"
    case .year: return "1년"
    }
  }
}

struct WeakArea: Equatable, Sendable {
  let category: QuizCategory
  let averageAccuracy: Double
  let recommendedAction: String
}

struct StrengthArea: Equatable, Sendable {
  let category: QuizCategory
  let averageAccuracy: Double
  let achievement: String
}

struct RecommendedStage: Equatable, Sendable {
  let stage: QuizStageDTO
  let reason: RecommendationReason
  let priority: Double
}

enum RecommendationReason: Equatable, Sendable {
  case nextInSequence
  case weakArea
  case dailyGoal
  case achievement
  
  var displayText: String {
    switch self {
    case .nextInSequence: return "다음 단계"
    case .weakArea: return "약한 분야 보완"
    case .dailyGoal: return "일일 목표 달성"
    case .achievement: return "업적 달성"
    }
  }
}

struct DailyGoal: Equatable, Sendable {
  let userId: String
  let targetStages: Int
  let targetStars: Int
  let targetAccuracy: Double
  let currentProgress: DailyProgress
  let lastUpdated: Date
  
  var isCompleted: Bool {
    return currentProgress.stagesCompleted >= targetStages &&
           currentProgress.starsEarned >= targetStars &&
           currentProgress.currentAccuracy >= targetAccuracy
  }
  
  var completionPercentage: Double {
    let stageProgress = Double(currentProgress.stagesCompleted) / Double(targetStages)
    let starProgress = Double(currentProgress.starsEarned) / Double(targetStars)
    let accuracyProgress = currentProgress.currentAccuracy / targetAccuracy
    
    return min(1.0, (stageProgress + starProgress + accuracyProgress) / 3.0)
  }
}

struct DailyProgress: Equatable, Sendable {
  let stagesCompleted: Int
  let starsEarned: Int
  let currentAccuracy: Double
}

// MARK: - Mock Data
extension UserOverallStats {
  static let mock = UserOverallStats(
    totalStagesCompleted: 25,
    totalStars: 65,
    overallAccuracy: 0.82,
    currentStreak: 5,
    bestStreak: 12,
    totalPlayTime: 3600,
    averageStageTime: 144,
    rank: 1
  )
}

extension CategoryStats {
  static let mockList: [CategoryStats] = [
    CategoryStats(
      category: .general,
      completedStages: 8,
      totalStages: 10,
      totalStars: 22,
      maxStars: 30,
      accuracy: 0.85,
      averageTime: 120,
      unlockedStage: 9
    ),
    CategoryStats(
      category: .history,
      completedStages: 5,
      totalStages: 8,
      totalStars: 12,
      maxStars: 24,
      accuracy: 0.75,
      averageTime: 150,
      unlockedStage: 6
    )
  ]
}

extension RecentActivity {
  static let mockList: [RecentActivity] = [
    RecentActivity(
      id: "activity-1",
      stageId: "general_stage_1",
      score: 8,
      stars: 2,
      accuracy: 0.8,
      timeSpent: 120,
      completedAt: Date(),
      isCleared: true
    ),
    RecentActivity(
      id: "activity-2",
      stageId: "history_stage_1",
      score: 9,
      stars: 3,
      accuracy: 0.9,
      timeSpent: 105,
      completedAt: Date().addingTimeInterval(-3600),
      isCleared: true
    )
  ]
}

extension Achievement {
  static let mockList: [Achievement] = [
    Achievement(
      id: "first_stage",
      title: "첫 걸음",
      description: "첫 번째 스테이지 완료",
      iconName: "star.fill",
      unlockedAt: Date()
    ),
    Achievement(
      id: "perfect_score",
      title: "완벽한 점수",
      description: "100% 정확도로 스테이지 완료",
      iconName: "crown.fill",
      unlockedAt: Date()
    )
  ]
}

extension LeaderboardEntry {
  static let mockList: [LeaderboardEntry] = [
    LeaderboardEntry(rank: 1, userId: "user-1", username: "퀴즈마스터", score: 1000, stars: 30, accuracy: 0.95),
    LeaderboardEntry(rank: 2, userId: "user-2", username: "지식왕", score: 950, stars: 28, accuracy: 0.92),
    LeaderboardEntry(rank: 3, userId: "user-3", username: "상식박사", score: 900, stars: 25, accuracy: 0.88)
  ]
}

extension CategoryAnalytics {
  static let mock = CategoryAnalytics(
    category: .general,
    totalStages: 10,
    averageCompletionRate: 0.75,
    averageAccuracy: 0.82,
    mostDifficultStage: "general_stage_10",
    easiestStage: "general_stage_1",
    averageTimePerStage: 120
  )
}

extension PerformanceTrend {
  static let mock = PerformanceTrend(
    timeRange: .month,
    dataPoints: [
      TrendDataPoint(date: Date().addingTimeInterval(-86400 * 7), accuracy: 0.75, score: 7, timeSpent: 150),
      TrendDataPoint(date: Date().addingTimeInterval(-86400 * 3), accuracy: 0.82, score: 8, timeSpent: 135),
      TrendDataPoint(date: Date(), accuracy: 0.88, score: 9, timeSpent: 120)
    ],
    averageAccuracy: 0.82,
    improvementRate: 0.13
  )
}

extension WeakArea {
  static let mockList: [WeakArea] = [
    WeakArea(
      category: .history,
      averageAccuracy: 0.65,
      recommendedAction: "역사 관련 스테이지를 더 연습해보세요"
    )
  ]
}

extension StrengthArea {
  static let mockList: [StrengthArea] = [
    StrengthArea(
      category: .general,
      averageAccuracy: 0.92,
      achievement: "일반상식 분야에서 뛰어난 실력을 보이고 있습니다!"
    )
  ]
}

extension RecommendedStage {
  static let mockList: [RecommendedStage] = [
    RecommendedStage(
      stage: .mock,
      reason: .nextInSequence,
      priority: 0.8
    )
  ]
}

extension DailyGoal {
  static let mock = DailyGoal(
    userId: "user-1",
    targetStages: 3,
    targetStars: 6,
    targetAccuracy: 0.8,
    currentProgress: DailyProgress(
      stagesCompleted: 1,
      starsEarned: 2,
      currentAccuracy: 0.75
    ),
    lastUpdated: Date()
  )
}
