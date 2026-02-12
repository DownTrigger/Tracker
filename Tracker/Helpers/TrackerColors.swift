import UIKit

enum TrackerColors {
    static let palette: [UIColor] = [
        UIColor(red: 0.99, green: 0.30, blue: 0.24, alpha: 1),
        UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1),
        UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1),
        UIColor(red: 0.45, green: 0.83, blue: 0.49, alpha: 1),
        UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1),
        UIColor(red: 0.20, green: 0.66, blue: 0.53, alpha: 1),
        UIColor(red: 0.12, green: 0.59, blue: 0.95, alpha: 1),
        UIColor(red: 0.38, green: 0.37, blue: 0.93, alpha: 1),
        UIColor(red: 0.91, green: 0.33, blue: 0.54, alpha: 1),
    ]

    static func color(at index: Int) -> UIColor {
        let safe = (index % palette.count + palette.count) % palette.count
        return palette[safe]
    }
}
