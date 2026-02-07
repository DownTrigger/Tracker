import Foundation

extension Date {

    static func trackerDateString(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
