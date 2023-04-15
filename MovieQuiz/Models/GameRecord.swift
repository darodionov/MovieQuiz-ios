import Foundation

struct GameRecord: Codable, Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        func score (gameResult: GameRecord) -> Double {
            guard gameResult.total != 0 else {
                return 0
            }
            return Double(gameResult.correct) / Double(gameResult.total)
        }
        
        return score(gameResult: lhs) < score(gameResult: rhs)
    }
    
    let correct: Int
    let total: Int
    let date: Date
}
