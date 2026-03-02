import UIKit

enum TrackerColors {

    // MARK: - Palette
    static let palette: [UIColor] = {
        var colors: [UIColor] = []
        
        for index in 1...18 {
            if let color = UIColor(named: "colorSelection\(index)") {
                colors.append(color)
            }
        }
        
        return colors
    }()

    // MARK: - Public
    static func color(at index: Int) -> UIColor {
        guard !palette.isEmpty else { return .systemBlue }
        let safe = (index % palette.count + palette.count) % palette.count
        return palette[safe]
    }
}
