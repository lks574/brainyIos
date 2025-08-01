import ComposableArchitecture
import SwiftUI

struct QuizResultPage: View {
  @Bindable var store: StoreOf<QuizResultReducer>

  var body: some View {
    VStack(spacing: 32) {
      // 헤더
      VStack(spacing: 16) {
        Text("퀴즈 완료!")
          .font(.brainyTitle)
          .foregroundColor(.brainyText)
        
        Text(store.session.category.displayName)
          .font(.brainyTitleLarge)
          .foregroundColor(.brainyTextSecondary)
      }
      
      // 점수 카드
      VStack(spacing: 24) {
        // 메인 점수
        VStack(spacing: 8) {
          Text("\(store.session.correctAnswers)")
            .font(.system(size: 64, weight: .bold))
            .foregroundColor(.brainyPrimary)
          
          Text("/ \(store.session.totalQuestions)")
            .font(.brainyTitleMedium)
            .foregroundColor(.brainyTextSecondary)
          
          Text("정답")
            .font(.brainyBody)
            .foregroundColor(.brainyText)
        }
        
        // 정확도 표시
        VStack(spacing: 8) {
          Text("\(Int(store.session.accuracy * 100))%")
            .font(.brainyTitleMedium)
            .foregroundColor(.brainyText)
          
          Text("정확도")
            .font(.brainyCaption)
            .foregroundColor(.brainyTextSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.brainyCardBackground)
        .cornerRadius(12)
      }
      .padding(24)
      .background(Color.brainyCardBackground)
      .cornerRadius(16)
      
      // 추가 정보
      VStack(spacing: 12) {
        HStack {
          Text("소요 시간")
            .font(.brainyBody)
            .foregroundColor(.brainyTextSecondary)
          
          Spacer()
          
          Text(formattedTime)
            .font(.brainyBody)
            .foregroundColor(.brainyText)
        }
        
        HStack {
          Text("퀴즈 모드")
            .font(.brainyBody)
            .foregroundColor(.brainyTextSecondary)
          
          Spacer()
          
          Text(store.session.mode.displayName)
            .font(.brainyBody)
            .foregroundColor(.brainyText)
        }
      }
      .padding(20)
      .background(Color.brainyCardBackground)
      .cornerRadius(12)
      
      Spacer()
      
      // 액션 버튼들
      VStack(spacing: 12) {
        BrainyButton("다시 퀴즈하기", style: .primary) {
          store.send(.goToCategorySelection(.multipleChoice))
        }

        BrainyButton("뒤로 가기", style: .secondary) {
          store.send(.goToBack)
        }
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.brainyBackground)
    .navigationBarHidden(true)
  }
  
  private var formattedTime: String {
    let minutes = Int(store.session.totalTime) / 60
    let seconds = Int(store.session.totalTime) % 60
    return String(format: "%d분 %02d초", minutes, seconds)
  }
}
