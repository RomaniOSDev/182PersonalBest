import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !viewModel.isLastPage {
                    Button("Skip") {
                        finishOnboarding()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .frame(height: 44)

            TabView(selection: $viewModel.currentPage) {
                ForEach(viewModel.pages) { page in
                    OnboardingPageView(page: page)
                        .tag(page.id)
                        .padding(.horizontal, 16)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)

            pageIndicator
                .padding(.bottom, 20)

            VStack(spacing: 12) {
                AppPrimaryButton(viewModel.primaryButtonTitle, icon: viewModel.isLastPage ? "checkmark" : "arrow.right") {
                    if viewModel.isLastPage {
                        finishOnboarding()
                    } else {
                        viewModel.nextPage()
                    }
                }

                if !viewModel.isLastPage {
                    AppSecondaryButton(title: "Skip for now") {
                        finishOnboarding()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .screenBackground()
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.pages) { page in
                Capsule()
                    .fill(page.id == viewModel.currentPage ? AppTheme.accent : AppTheme.accent.opacity(0.2))
                    .frame(width: page.id == viewModel.currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
            }
        }
    }

    private func finishOnboarding() {
        viewModel.complete()
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
