import ComposableArchitecture
import SwiftUI

struct QuizResultPage: View {
  @Bindable var store: StoreOf<QuizResultReducer>

  var body: some View {
    ZStack {
      Color.brainyBackground
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        // Header with celebration
        headerView
        
        ScrollView {
          VStack(spacing: 24) {
            // Main result card
            resultCardView
            
            // Statistics
            statisticsView
            
            // Action buttons
            actionButtonsView
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 32)
        }
      }
    }
    .navigationBarHidden(true)
  }
}

extension QuizResultPage {
  private var headerView: some View {
    VStack(spacing: 16) {
      // Close button
      HStack {
        Spacer()
        
        Button(action: {
          store.send(.goToBack)
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.brainyTextSecondary)
        }
      }
      .padding(.horizontal, 24)
      .padding(.top, 16)
      
      // Celebration
      VStack(spacing: 12) {
        Text(store.congratulationMessage)
          .font(.brainyTitleLarge)
          .foregroundColor(.brainyText)
        
        Text(store.stageDisplayName)
          .font(.brainyHeadlineMedium)
          .foregroundColor(.brainyTextSecondary)
      }
      .padding(.bottom, 8)
    }
  }
  
  private var resultCardView: some View {
    BrainyCard(style: .default, shadow: .medium) {
      VStack(spacing: 24) {
        // Clear status
        VStack(spacing: 8) {
          Image(systemName: store.isCleared ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 48))
            .foregroundColor(store.isCleared ? .brainySuccess : .brainyError)
          
          Text(store.isCleared ? "클리어!" : "아쉬워요")
            .font(.brainyHeadlineMedium)
            .foregroundColor(store.isCleared ? .brainySuccess : .brainyError)
        }
        
        // Score
        VStack(spacing: 8) {
          HStack(alignment: .bottom, spacing: 4) {
            Text("\(store.stageResult.score)")
              .font(.system(size: 56, weight: .bold))
              .foregroundColor(.brainyPrimary)
            
            Text("/ 10")
              .font(.brainyTitleMedium)
              .foregroundColor(.brainyTextSecondary)
              .padding(.bottom, 8)
          }
          
          Text("정답")
            .font(.brainyBodyLarge)
            .foregroundColor(.brainyText)
        }
        
        // Stars
        if store.stageResult.stars > 0 {
          VStack(spacing: 8) {
            Text(store.stageResult.starsDisplay)
              .font(.brainyTitleMedium)
            
            Text("획득한 별")
              .font(.brainyBodyMedium)
              .foregroundColor(.brainyTextSecondary)
          }
        }
      }
      .padding(32)
    }
  }
  
  private var statisticsView: some View {
    VStack(spacing: 16) {
      // Accuracy
      statisticRowView(
        icon: "target",
        title: "정확도",
        value: store.stageResult.accuracyPercentage,
        color: accuracyColor
      )
      
      // Time
      statisticRowView(
        icon: "clock",
        title: "소요 시간",
        value: formattedTime,
        color: .brainyTextSecondary
      )
      
      // Clear status
      statisticRowView(
        icon: store.isCleared ? "checkmark.circle.fill" : "xmark.circle.fill",
        title: "클리어 여부",
        value: store.isCleared ? "성공" : "실패",
        color: store.isCleared ? .brainySuccess : .brainyError
      )
    }
  }
  
  private func statisticRowView(icon: String, title: String, value: String, color: Color) -> some View {
    BrainyCard(style: .default, shadow: .small) {
      HStack(spacing: 16) {
        Image(systemName: icon)
          .font(.system(size: 20))
          .foregroundColor(color)
          .frame(width: 24)
        
        Text(title)
          .font(.brainyBodyLarge)
          .foregroundColor(.brainyText)
        
        Spacer()
        
        Text(value)
          .font(.brainyBodyLarge)
          .fontWeight(.medium)
          .foregroundColor(color)
      }
      .padding(16)
    }
  }
  
  private var actionButtonsView: some View {
    VStack(spacing: 12) {
      // Primary actions
      HStack(spacing: 12) {
        BrainyButton("다시 도전", style: .primary) {
          store.send(.retryStage)
        }
        
        BrainyButton("다른 퀴즈", style: .secondary) {
          store.send(.goToCategorySelection(.multipleChoice))
        }
      }
      
      // Secondary action
      BrainyButton("히스토리 보기", style: .ghost) {
        store.send(.goToHistory)
      }
    }
  }
  
  private var accuracyColor: Color {
    let accuracy = store.stageResult.accuracy
    if accuracy >= 0.9 {
      return .brainySuccess
    } else if accuracy >= 0.7 {
      return .brainyWarning
    } else {
      return .brainyError
    }
  }
  
  private var formattedTime: String {
    let minutes = Int(store.stageResult.timeSpent) / 60
    let seconds = Int(store.stageResult.timeSpent) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
}
