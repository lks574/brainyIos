import ComposableArchitecture
import SwiftUI

@Reducer
struct QuizPlayReducer {
  @Dependency(\.navigation) var navigation
  @Dependency(\.quizClient) var quizClient

  @ObservableState
  struct State: Equatable {
    let quizType: QuizType
    let stageId: String
    let quizCategory: QuizCategory

    var currentQuestionIndex: Int = 0
    var quizQuestions: [QuizQuestionDTO] = []
    var selectedOptionIndex: Int?
    var shortAnswerText: String = ""
    var isLastQuestion: Bool = false

    var timeRemaining: Int = 0
    var progress: Float = 0
    var score: Int = 0

    var isLoading: Bool = false
    var errorMessage: String?

    var hasAnswered: Bool {
      if let question = currentQuestion {
        switch question.type {
        case .multipleChoice:
          return selectedOptionIndex != nil
        case .shortAnswer:
          return !shortAnswerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .voice, .ai:
          return !shortAnswerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
      }
      return false
    }

    var currentQuestion: QuizQuestionDTO? {
      if quizType == .ai {
        return nil
      } else {
        guard currentQuestionIndex < quizQuestions.count else { return nil }
        return quizQuestions[currentQuestionIndex]
      }
    }

    init(quizType: QuizType, stageId: String, quizCategory: QuizCategory) {
      self.quizType = quizType
      self.stageId = stageId
      self.quizCategory = quizCategory
    }
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack

    case startStage
    case submitAnswer
    case changeShortAnswerText(String)
    case selectOption(Int)
    case completeStage

    case getStageQuestions
    case stageQuestionsLoaded([QuizQuestionDTO])
    case stageQuestionsLoadFailed(String)
    case stageCompleted(QuizStageResultDTO)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .goToBack:
        return .run { _ in
          await navigation.goToBack()
        }

      case .startStage:
        return .send(.getStageQuestions)

      case .submitAnswer:
        // 답변이 있는지 확인
        guard state.hasAnswered else { return .none }
        
        // 정답 체크 및 점수 업데이트
        if let currentQuestion = state.currentQuestion {
          let isCorrect = checkAnswer(question: currentQuestion, 
                                    selectedIndex: state.selectedOptionIndex, 
                                    shortAnswer: state.shortAnswerText)
          if isCorrect {
            state.score += 1
          }
        }
        
        // 다음 문제로 이동
        if state.currentQuestionIndex < state.quizQuestions.count - 1 {
          state.currentQuestionIndex += 1
          state.selectedOptionIndex = nil
          state.shortAnswerText = ""
          
          // 진행률 업데이트
          state.progress = Float(state.currentQuestionIndex) / Float(state.quizQuestions.count)
          
          // 마지막 문제인지 확인
          state.isLastQuestion = state.currentQuestionIndex == state.quizQuestions.count - 1
        } else {
          // 스테이지 완료
          return .send(.completeStage)
        }
        
        return .none
        
      case .completeStage:
        // 스테이지 결과 저장 로직
        return .run { [stageId = state.stageId, score = state.score] send in
          // TODO: 스테이지 결과 저장 및 사용자 통계 업데이트
          // let result = QuizStageResultEntity(...)
          // await send(.stageCompleted(result))
        }

      case .changeShortAnswerText(let shortAnswerText):
        state.shortAnswerText = shortAnswerText
        return .none

      case .selectOption(let optionIndex):
        state.selectedOptionIndex = optionIndex
        return .none

      case .getStageQuestions:
        state.isLoading = true
        state.errorMessage = nil
        return .none
//        return .run { [stageId = state.stageId] send in
//          do {
//            // 스테이지별 문제 로드
//            let questions = try await quizClient.fetchStageQuestions(stageId: stageId)
//            await send(.stageQuestionsLoaded(questions))
//          } catch {
//            await send(.stageQuestionsLoadFailed(error.localizedDescription))
//          }
//        }
        
      case .stageQuestionsLoaded(let questions):
        state.isLoading = false
        state.quizQuestions = questions
        state.progress = 0.0
        state.score = 0
        return .none
        
      case .stageQuestionsLoadFailed(let errorMessage):
        state.isLoading = false
        state.errorMessage = errorMessage
        return .none
        
      case .stageCompleted(let result):
        // 스테이지 완료 후 결과 페이지로 이동
        return .run { _ in
          // TODO: 결과 페이지로 네비게이션
          await navigation.goToBack()
        }
      }
    }
  }

  // MARK: - Helper Functions

  /// 답변 체크 함수
  private func checkAnswer(question: QuizQuestionDTO, selectedIndex: Int?, shortAnswer: String) -> Bool {
    switch question.type {
    case .multipleChoice:
      guard let selectedIndex = selectedIndex,
            let options = question.options,
            selectedIndex < options.count else { return false }
      return options[selectedIndex] == question.correctAnswer

    case .shortAnswer, .voice, .ai:
      let userAnswer = shortAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
      let correctAnswer = question.correctAnswer.lowercased()
      return userAnswer == correctAnswer
    }
  }
}
