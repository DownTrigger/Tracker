import Foundation

extension Date {

    // MARK: - Formatting
    private static let trackerDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        f.locale = .current
        return f
    }()

    static func trackerDateString(from date: Date = Date()) -> String {
        trackerDateFormatter.string(from: date)
    }
}
