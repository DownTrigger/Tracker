import Foundation

final class StatisticsViewModel {
    var onStateUpdated: (() -> Void)?
    private(set) var isEmpty = true
}
