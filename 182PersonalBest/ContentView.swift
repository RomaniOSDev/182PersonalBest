import SwiftUI

struct ContentView: View {
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
