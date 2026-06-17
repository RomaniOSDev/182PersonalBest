import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(hex: "#F4F6FA")
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: "#8E9AAB")
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "#8E9AAB")]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(hex: "#4A91D6")
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "#4A91D6")]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(hex: "#F4F6FA")
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(hex: "#153254")]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(hex: "#153254")]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(hex: "#4A91D6")
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
                .tag(1)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(2)

            WorkoutListView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(4)
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    MainTabView()
}
