import AppMetricaCore

final class AnalyticsService {

    static let shared = AnalyticsService()
    private init() {}

    func reportOpen(screen: String) {
        report(event: "open", screen: screen, item: nil)
    }

    func reportClose(screen: String) {
        report(event: "close", screen: screen, item: nil)
    }

    func reportClick(screen: String, item: String) {
        report(event: "click", screen: screen, item: item)
    }

    private func report(event: String, screen: String, item: String?) {
        var params: [String: String] = ["event": event, "screen": screen]
        if let item {
            params["item"] = item
        }
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("AppMetrica error: \(error)")
        })
        #if DEBUG
        print("Analytics: event=\(event), screen=\(screen)" + (item.map { ", item=\($0)" } ?? ""))
        #endif
    }
}
