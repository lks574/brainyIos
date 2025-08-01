import SwiftUI

struct CategorySelectionCategoryCard: View {
  let category: QuizCategory
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 12) {
        Text(categoryIcon)
          .font(.system(size: 32))
        
        Text(category.rawValue)
          .font(.brainyBodyLarge)
          .foregroundColor(titleColor)
          .multilineTextAlignment(.center)
        
        Text(categoryDescription)
          .font(.brainyBodySmall)
          .foregroundColor(.brainyTextSecondary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
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
    case .all: "🗂️"
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
    case .all: "모든 퀴즈"
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
}
