import Foundation
import Combine

final class WordCounterViewModel: ObservableObject {
    @Published var input: String = ""

    var stats: TextStatistics {
        TextProcessingService.statistics(for: input)
    }
}
