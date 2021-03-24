//
//  GameSettings.swift


import Foundation

enum GameResult: Int {
    case veryBad = 0
    case bad = 1
    case normal = 2
    case good = 3
}

enum TimeResult {
    case veryBad
    case bad
    case normal
    case good
}

enum FlipsCountResult {
    case veryBad
    case bad
    case normal
    case good
}

struct GameSettings {
    let rows: Int
    let columns: Int
}
    
    //    let times: [Int]
    //    let flipsCounts: [Int]
    //    let pointsForStar: Int
    //
    //    var price: Int
    //
    //    var title: String {
    //        return "\(rows)x\(columns) (\(rows * columns) tiles)"

//var priceTitle: String? {
//    return price == 0 ? nil : "Buy: \(price) star"
//}

//func gameResultFor(time: Int, flipsCount: Int) -> GameResult {
//    let timeResult = timeResultForTime(time, flipsCount: flipsCount)
//    let flipCountResult = flipsCountResultForFlipsCount(flipsCount)
//
//    if (timeResult == .good && flipCountResult == .good) || (timeResult == .normal && flipCountResult == .good) {
//        return .good
//    } else if (timeResult == .good && flipCountResult == .normal) || (timeResult == .normal && flipCountResult == .normal) || (timeResult == .bad && flipCountResult == .good) {
//        return .normal
//    } else if (timeResult == .good && flipCountResult == .bad) || (timeResult == .normal && flipCountResult == .bad) || (timeResult == .bad && flipCountResult == .normal) {
//        return .bad
//    } else {
//        return .veryBad
//    }
//}
//
//func timeResultForTime(_ time: Int, flipsCount: Int) -> TimeResult {
//    if time <= flipsCount {
//        return .good
//    } else if time <= 4 * flipsCount / 3 {
//        return .normal
//    } else if time <= 3 * flipsCount / 2 {
//        return .bad
//    } else {
//        return .veryBad
//    }
//
//    //        if time < times[0] {
    //            return .veryBad
    //        } else if time < times[1] {
    //            return .bad
    //        } else if time < times[2] {
    //            return .normal
    //        } else {
    //            return .good
    //        }


//func flipsCountResultForFlipsCount(_ flipsCount: Int) -> FlipsCountResult {
//    let flipsCountDoubleValue = Double(flipsCount)
//
//    let coef = rows * columns > 16 ? 0.2 : 0
//    if flipsCountDoubleValue <= (2.0 + coef) * Double(rows * columns) {
//        return .good
//    } else if flipsCountDoubleValue <= (2.2 + coef) * Double(rows * columns) {
//        return .normal
//    } else if flipsCountDoubleValue <= (2.4 + coef) * Double(rows * columns) {
//        return .bad
//    } else {
//        return .veryBad
//    }
    
    //        if flipsCount < flipsCounts[0] {
    //            return .veryBad
    //        } else if flipsCount < flipsCounts[1] {
    //            return .bad
    //        } else if flipsCount < flipsCounts[2] {
    //            return .normal
    //        } else {
    //            return .good
    //        }
//}
//
//func scoreForGameResult(_ gameResult: GameResult) -> Int {
//    return gameResult.rawValue * pointsForStar
//}
//}
