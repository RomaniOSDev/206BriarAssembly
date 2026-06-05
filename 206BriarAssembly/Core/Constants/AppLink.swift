import UIKit

enum AppLink: String {
    case privacyPolicy = "https://briar206assembly.site/privacy/240"
    case termsOfService = "https://briar206assembly.site/terms/240"

    var url: URL? {
        URL(string: rawValue)
    }

    func open() {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
