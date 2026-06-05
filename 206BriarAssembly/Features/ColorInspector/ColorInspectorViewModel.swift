import Foundation
import Combine
import SwiftUI
import UIKit
import AudioToolbox

struct ColorFormatResult: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let value: String
}

final class ColorInspectorViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var results: [ColorFormatResult] = []
    @Published var parsedColor: Color?
    @Published var errorMessage: String?
    @Published var shakeTrigger = 0
    @Published var resultPulse = false
    private let storage: AppStorage

    var showEmptyState: Bool {
        storage.recentColors.isEmpty && results.isEmpty
    }

    var canInspect: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(storage: AppStorage) {
        self.storage = storage
    }

    func inspect() {
        errorMessage = nil
        results = []
        parsedColor = nil

        guard let rgb = parseInput(input) else {
            errorMessage = "Enter a valid hex, RGB, or HSL color code."
            shakeTrigger += 1
            HapticManager.warning()
            return
        }

        let hex = String(format: "#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
        let rgbString = "rgb(\(rgb.r), \(rgb.g), \(rgb.b))"
        let hsl = rgbToHSL(r: rgb.r, g: rgb.g, b: rgb.b)
        let hslString = String(format: "hsl(%.0f, %.0f%%, %.0f%%)", hsl.h, hsl.s * 100, hsl.l * 100)

        results = [
            ColorFormatResult(name: "Hex", value: hex),
            ColorFormatResult(name: "RGB", value: rgbString),
            ColorFormatResult(name: "HSL", value: hslString)
        ]
        parsedColor = Color(red: Double(rgb.r) / 255, green: Double(rgb.g) / 255, blue: Double(rgb.b) / 255)
        storage.addRecentColor(hex)
        storage.recordColorInspection()

        HapticManager.mediumTap()
        AudioServicesPlaySystemSound(1103)
        resultPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.resultPulse = false
        }
    }

    func copyValue(_ value: String) {
        UIPasteboard.general.string = value
        HapticManager.lightTap()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057)
    }

    func copyHex(_ hex: String) {
        copyValue(hex)
    }

    func color(fromHex hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            return Color("AppSurface")
        }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }

    private struct RGB {
        let r: Int
        let g: Int
        let b: Int
    }

    private struct HSL {
        let h: Double
        let s: Double
        let l: Double
    }

    private func parseInput(_ text: String) -> RGB? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.hasPrefix("#") || trimmed.count == 6 || trimmed.count == 3 {
            return parseHex(trimmed.replacingOccurrences(of: "#", with: ""))
        }
        if trimmed.hasPrefix("rgb") {
            return parseRGBFunction(trimmed)
        }
        if trimmed.hasPrefix("hsl") {
            return parseHSLFunction(trimmed)
        }
        if trimmed.allSatisfy({ $0.isHexDigit }) {
            return parseHex(trimmed)
        }
        return nil
    }

    private func parseHex(_ hex: String) -> RGB? {
        var value = hex
        if value.count == 3 {
            value = value.map { String($0) + String($0) }.joined()
        }
        guard value.count == 6, let intVal = Int(value, radix: 16) else { return nil }
        return RGB(
            r: (intVal >> 16) & 0xFF,
            g: (intVal >> 8) & 0xFF,
            b: intVal & 0xFF
        )
    }

    private func parseRGBFunction(_ text: String) -> RGB? {
        let numbers = text
            .replacingOccurrences(of: "rgb", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard numbers.count == 3,
              numbers.allSatisfy({ $0 >= 0 && $0 <= 255 }) else { return nil }
        return RGB(r: numbers[0], g: numbers[1], b: numbers[2])
    }

    private func parseHSLFunction(_ text: String) -> RGB? {
        let cleaned = text
            .replacingOccurrences(of: "hsl", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "%", with: "")
        let parts = cleaned.split(separator: ",").map {
            Double($0.trimmingCharacters(in: .whitespaces)) ?? -1
        }
        guard parts.count == 3, parts[0] >= 0, parts[0] <= 360 else { return nil }
        let h = parts[0]
        let s = min(max(parts[1] / 100, 0), 1)
        let l = min(max(parts[2] / 100, 0), 1)
        return hslToRGB(h: h, s: s, l: l)
    }

    private func rgbToHSL(r: Int, g: Int, b: Int) -> HSL {
        let rf = Double(r) / 255
        let gf = Double(g) / 255
        let bf = Double(b) / 255
        let maxC = max(rf, gf, bf)
        let minC = min(rf, gf, bf)
        let delta = maxC - minC
        var h: Double = 0
        let l = (maxC + minC) / 2
        var s: Double = 0
        if delta != 0 {
            s = delta / (1 - abs(2 * l - 1))
            if maxC == rf {
                h = 60 * (((gf - bf) / delta).truncatingRemainder(dividingBy: 6))
            } else if maxC == gf {
                h = 60 * (((bf - rf) / delta) + 2)
            } else {
                h = 60 * (((rf - gf) / delta) + 4)
            }
        }
        if h < 0 { h += 360 }
        return HSL(h: h, s: s, l: l)
    }

    private func hslToRGB(h: Double, s: Double, l: Double) -> RGB {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2
        let (r1, g1, b1): (Double, Double, Double)
        switch h {
        case 0..<60: (r1, g1, b1) = (c, x, 0)
        case 60..<120: (r1, g1, b1) = (x, c, 0)
        case 120..<180: (r1, g1, b1) = (0, c, x)
        case 180..<240: (r1, g1, b1) = (0, x, c)
        case 240..<300: (r1, g1, b1) = (x, 0, c)
        default: (r1, g1, b1) = (c, 0, x)
        }
        return RGB(
            r: Int(((r1 + m) * 255).rounded()),
            g: Int(((g1 + m) * 255).rounded()),
            b: Int(((b1 + m) * 255).rounded())
        )
    }
}

private extension Character {
    var isHexDigit: Bool {
        ("0"..."9").contains(self) || ("a"..."f").contains(self) || ("A"..."F").contains(self)
    }
}
