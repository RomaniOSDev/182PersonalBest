import Foundation

enum AppLinks: String {
    case privacyPolicy = "https://www.termsfeed.com/live/a1b15cf3-63f7-4851-8b4f-61dc26dfa532"
    case termsOfUse = "https://www.termsfeed.com/live/5c50046d-74bf-48a1-88a0-139b95f1e523"

    var url: URL? {
        URL(string: rawValue)
    }
}
