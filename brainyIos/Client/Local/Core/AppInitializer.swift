import Foundation
import ComposableArchitecture

@MainActor
struct AppInitializer {
  @Dependency(\.quizClient) var quizClient
  
  func initializeApp() async {
    do {
      // Load initial quiz data if needed
      try await quizClient.loadInitialDataIfNeeded()
      print("App initialization completed successfully")
    } catch {
      print("Failed to initialize app: \(error)")
    }
  }
}

// MARK: - Usage Example
/*
 앱의 main view나 App.swift에서 다음과 같이 사용:
 
 struct BrainyApp: App {
   var body: some Scene {
     WindowGroup {
       ContentView()
         .task {
           await AppInitializer().initializeApp()
         }
     }
   }
 }
 
 또는 ContentView에서:
 
 struct ContentView: View {
   var body: some View {
     // Your main content
     Text("Hello World")
       .task {
         await AppInitializer().initializeApp()
       }
   }
 }
*/