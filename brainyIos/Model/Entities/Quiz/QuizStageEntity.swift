import Foundation
import SwiftData

@Model
final class QuizStageEntity {
  @Attribute(.unique) var id: String
  var stageNumber: Int
  var category: String
  var difficulty: String
  var title: String
  var requiredAccuracy: Double = 0.7  // 70% 클리어 기준
  var totalQuestions: Int = 10
  var createdAt: Date
  
  // 관계
  @Relationship(deleteRule: .cascade) var stageResults: [QuizStageResultEntity] = []
  @Relationship(deleteRule: .cascade) var questions: [QuizQuestionEntity] = []
  
  init(id: String, stageNumber: Int, category: QuizCategory, difficulty: QuizDifficulty, title: String) {
    self.id = id
    self.stageNumber = stageNumber
    self.category = category.rawValue
    self.difficulty = difficulty.rawValue
    self.title = title
    self.createdAt = Date()
  }
  
  /// 카테고리 enum 반환
  var categoryEnum: QuizCategory {
    return QuizCategory(rawValue: category) ?? .general
  }
  
  /// 난이도 enum 반환
  var difficultyEnum: QuizDifficulty {
    return QuizDifficulty(rawValue: difficulty) ?? .easy
  }
  
  /// 스테이지 완료 여부 확인 (특정 사용자)
  func isCompleted(by userId: String) -> Bool {
    return stageResults.contains { $0.userId == userId && $0.isCleared }
  }
  
  /// 스테이지 최고 기록 (특정 사용자)
  func bestResult(for userId: String) -> QuizStageResultEntity? {
    return stageResults
      .filter { $0.userId == userId }
      .max { $0.score < $1.score }
  }
}
\
/*
 맞습니다! 불필요한 복잡성을 제거하고 더 간단하고 효율적인 구조로 만들어보겠습니다.

 🎯 간소화된 Stage 중심 테이블 구조
 🗂️ 핵심 테이블만 유지
 1. UserEntity (사용자) - 간소화
 UserEntity {
   id: String (PK, Unique)
   username: String
   email: String?
   profileImageURL: String?
   createdAt: Date
   updatedAt: Date

   -- 핵심 통계만
   totalStagesCompleted: Int = 0
   totalStars: Int = 0
   currentStreak: Int = 0
   bestStreak: Int = 0

   -- 관계
   stageResults: [QuizStageResultEntity]
 }
 2. QuizStageEntity (스테이지)
 QuizStageEntity {
   id: String (PK, Unique)
   stageNumber: Int
   category: QuizCategory
   difficulty: QuizDifficulty
   title: String
   requiredAccuracy: Double = 0.7  -- 70% 클리어 기준
   totalQuestions: Int = 10

   -- 관계
   stageResults: [QuizStageResultEntity]
   questions: [QuizQuestionEntity]
 }
 3. QuizStageResultEntity (스테이지 결과) - 핵심
 QuizStageResultEntity {
   id: String (PK, Unique)
   userId: String (FK → UserEntity.id)
   stageId: String (FK → QuizStageEntity.id)
   score: Int                    -- 맞춘 문제 수 (0-10)
   stars: Int                    -- 별점 (1-3개)
   timeSpent: TimeInterval
   isCleared: Bool               -- 70% 이상 여부
   completedAt: Date

   -- 관계
   user: UserEntity
   stage: QuizStageEntity
 }
 4. QuizQuestionEntity (퀴즈 문제) - 간소화
 QuizQuestionEntity {
   id: String (PK, Unique)
   question: String
   correctAnswer: String
   options: [String]?
   category: String
   difficulty: String
   type: String
   audioURL: String?
   stageId: String? (FK → QuizStageEntity.id)
   orderInStage: Int?            -- 스테이지 내 순서 (1-10)

   -- 관계
   stage: QuizStageEntity
 }
 ❌ 제거할 테이블들
 제거 1: QuizCategoryProgressEntity
 이유: QuizStageResultEntity에서 카테고리별 진행상황을 계산할 수 있음
 대체 방법: 런타임에 계산하거나 캐시 사용
 제거 2: QuizSessionEntity
 이유: Stage 시스템에서는 세션 추적이 불필요
 대체 방법: QuizStageResultEntity가 세션 역할 대체
 제거 3: QuizResultEntity (문제별 결과)
 이유: Stage 단위로만 결과 관리하면 충분
 대체 방법: 필요시 클라이언트에서 임시 저장
 🔗 간소화된 관계도
 UserEntity (1) ←→ (N) QuizStageResultEntity ←→ (N) QuizStageEntity
                                                       ↓
                                             QuizQuestionEntity (N)
 📊 최종 테이블 구조 (4개 테이블만)
 1. UserEntity          -- 사용자 정보 + 기본 통계
 2. QuizStageEntity      -- 스테이지 정보 + 문제 구성
 3. QuizStageResultEntity -- 스테이지 플레이 결과
 4. QuizQuestionEntity   -- 문제 데이터
 🎯 데이터 흐름 간소화
 사용자가 스테이지 선택 → QuizStageEntity에서 문제 로드
 스테이지 완료 → QuizStageResultEntity 생성
 사용자 통계 업데이트 → UserEntity 업데이트
 다음 스테이지 해금 체크 → 이전 스테이지 결과 확인

 💡 런타임 계산으로 대체되는 정보들
 // 카테고리별 진행상황 (런타임 계산)
 func getCategoryProgress(for category: QuizCategory, userId: String) -> CategoryProgress {
   let results = user.stageResults.filter { $0.stage.category == category }
   let unlockedStage = results.filter { $0.isCleared }.count + 1
   let totalStars = results.reduce(0) { $0 + $1.stars }

   return CategoryProgress(
     currentUnlockedStage: unlockedStage,
     totalStars: totalStars,
     completedStages: results.count
   )
 }

 // 전체 통계 (런타임 계산)
 func updateUserStats() {
   totalStagesCompleted = stageResults.filter { $0.isCleared }.count
   totalStars = stageResults.reduce(0) { $0 + $1.stars }
 }
 ✅ 장점
 단순함: 4개 테이블로 모든 기능 구현
 성능: 불필요한 JOIN 연산 제거
 유지보수: 복잡한 관계 제거로 버그 가능성 감소
 확장성: 필요시 나중에 테이블 추가 가능
 🤔 고려사항
 문제별 상세 분석: 나중에 필요하면 QuizResultEntity 다시 추가
 세션 추적: 필요시 클라이언트에서 임시 관리
 통계 계산: 자주 사용되는 통계는 캐싱 고려
 이렇게 4개 테이블로 간소화하는 것이 어떠신가요? 더 제거할 부분이나 추가로 고려해야 할 사항이 있다면 말씀해 주세요!
 */
