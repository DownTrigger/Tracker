import AppMetricaCore

enum AnalyticsService {

    enum Event: String {
        case open
        case close
        case click
    }

    static func reportOpen(screen: String) {
        report(event: .open, screen: screen, item: nil)
    }

    static func reportClose(screen: String) {
        report(event: .close, screen: screen, item: nil)
    }

    static func reportClick(screen: String, item: String) {
        report(event: .click, screen: screen, item: item)
    }

    private static func report(event: Event, screen: String, item: String?) {
        var params: [String: String] = ["event": event.rawValue, "screen": screen]
        if let item {
            params["item"] = item
        }
        AppMetrica.reportEvent(name: event.rawValue, parameters: params, onFailure: { error in
            print("AppMetrica error: \(error)")
        })
        #if DEBUG
        print("Analytics: event=\(event.rawValue), screen=\(screen)" + (item.map { ", item=\($0)" } ?? ""))
        #endif
    }
}
