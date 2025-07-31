import SwiftUI

/// 음성 모드 퀴즈 전용 UI 컴포넌트
struct VoiceQuizView: View {

  let question: QuizQuestionDTO
  let onAnswerSubmitted: (String) -> Void

  var body: some View {
    VStack {
      Text("VoiceQuizView")
    }
  }
}
