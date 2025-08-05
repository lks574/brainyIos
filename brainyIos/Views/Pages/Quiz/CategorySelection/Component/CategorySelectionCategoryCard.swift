import SwiftUI

struct CategorySelectionCategoryCard: View {
  let category: QuizCategory
  let isSelected: Bool
  let progress: CategorySelectionReducer.CategoryProgress?
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Text(categoryIcon)
          .font(.system(size: 28))
        
        Text(category.displayName)
          .font(.brainyBodyLarge)
          .foregroundColor(titleColor)
          .multilineTextAlignment(.center)
        
        // 진행도 표시 또는 설명
        if let progress = progress, progress.totalStages > 0 {
          VStack(spacing: 4) {
            HStack(spacing: 4) {
              Text("\(progress.completedStages)/\(progress.totalStages)")
                .font(.brainyBodySmall)
                .foregroundColor(progressTextColor)
                .fontWeight(.medium)
              
              Text("스테이지")
                .font(.brainyBodySmall)
                .foregroundColor(.brainyTextSecondary)
            }
            
            // 진행도 바
            GeometryReader { geometry in
              ZStack(alignment: .leading) {
                Rectangle()
                  .fill(Color.brainySecondary.opacity(0.2))
                  .frame(height: 4)
                  .cornerRadius(2)
                
                Rectangle()
                  .fill(progressBarColor)
                  .frame(width: geometry.size.width * progress.progressPercentage, height: 4)
                  .cornerRadius(2)
                  .animation(.easeInOut(duration: 0.3), value: progress.progressPercentage)
              }
            }
            .frame(height: 4)
            
            // 완료 퍼센트 표시
            Text("\(Int(progress.progressPercentage * 100))% 완료")
              .font(.brainyCaption)
              .foregroundColor(progressTextColor)
          }
        } else {
          // 스테이지가 없는 카테고리는 "준비 중" 표시
          if let progress = progress, progress.totalStages == 0 {
            Text("준비 중")
              .font(.brainyBodySmall)
              .foregroundColor(.brainyTextSecondary)
              .multilineTextAlignment(.center)
          } else {
            Text(categoryDescription)
              .font(.brainyBodySmall)
              .foregroundColor(.brainyTextSecondary)
              .multilineTextAlignment(.center)
              .lineLimit(2)
          }
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 120)
      .padding(16)
      .background(backgroundColor)
      .cornerRadius(16)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(borderColor, lineWidth: borderWidth)
      )
      .scaleEffect(isSelected ? 1.05 : 1.0)
      .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    .buttonStyle(PlainButtonStyle())
  }
  
  private var categoryIcon: String {
    return switch category {
    case .general: "🧩"
    case .country: "🌍"
    case .drama: "🎭"
    case .history: "📜"
    case .person: "👤"
    case .music: "🎵"
    case .food: "🍽️"
    case .sports: "⚽"
    case .movie: "🎬"
    }
  }
  
  private var categoryDescription: String {
    return switch category {
    case .general: "일반상식 퀴즈"
    case .country: "세계 각국에 대한 퀴즈"
    case .drama: "유명 드라마 퀴즈"
    case .history: "세계 역사에 대한 퀴즈"
    case .person: "유명 인물에 대한 퀴즈"
    case .music: "음악과 가수 퀴즈"
    case .food: "세계 모든 음식 퀴즈"
    case .sports: "모든 스포츠 퀴즈"
    case .movie: "유명 영화 퀴즈"
    }
  }
  
  private var titleColor: Color {
    isSelected ? .brainyPrimary : .brainyText
  }
  
  private var backgroundColor: Color {
    isSelected ? Color.brainyPrimary.opacity(0.05) : .brainyCardBackground
  }
  
  private var borderColor: Color {
    isSelected ? .brainyPrimary : Color.brainySecondary.opacity(0.2)
  }
  
  private var borderWidth: CGFloat {
    isSelected ? 2.0 : 1.0
  }
  
  private var progressBarColor: Color {
    guard let progress = progress else { return .brainyPrimary }
    
    if progress.progressPercentage >= 1.0 {
      return .brainySuccess
    } else if progress.progressPercentage >= 0.5 {
      return .brainyPrimary
    } else {
      return .brainyAccent
    }
  }
  
  private var progressTextColor: Color {
    guard let progress = progress else { return .brainyTextSecondary }
    
    if progress.progressPercentage >= 1.0 {
      return .brainySuccess
    } else {
      return .brainyText
    }
  }
}
