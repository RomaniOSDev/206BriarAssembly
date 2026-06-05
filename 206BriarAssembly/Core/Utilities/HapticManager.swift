import UIKit
import AudioToolbox

enum HapticManager {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func playSuccessSound() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playTickSound() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playClipboardSound() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playInspectSound() {
        AudioServicesPlaySystemSound(1103)
    }

    static func completeAction() {
        mediumTap()
        playSuccessSound()
    }
}
