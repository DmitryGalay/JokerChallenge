////
////  Concentration.swift
//
//import Foundation
//
//class Concentration {
//    
//    private(set) var cards = [Card]()
//	private(set) var numberOfPairsOfCards: Int
//	private(set) var level: Int
//	var matchedCards: [Card] {
//		get {
//			return cards.filter({ (card) -> Bool in
//				return card.isFaceUp && card.isMatched
//			})
//		}
//	}
//	
//    var indexOfOneAndOnlyFaceUpCard: Int? {
//        get {
//            return cards.indices.filter  { (cards[$0].isFaceUp && !cards[$0].isMatched) }.oneAndOnly
//        }
//        set {
//            for index in cards.indices {
//                if cards[index].isMatched { continue }
//                cards[index].isFaceUp = (index == newValue)
//            }
//        }
//    }
//    
//    func chooseCard(at index: Int) {
//        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)) : Choosen index out of range")
//        if cards[index].isMatched { return }
//        
//        if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
//            // check if cards match
//            if cards[matchIndex] == cards[index] {
//                cards[matchIndex].isMatched = true
//                cards[index].isMatched = true
//            }
//            cards[index].isFaceUp = true
//        } else {
//            indexOfOneAndOnlyFaceUpCard = index
//        }
//    }
//    
//    var needToFlipBack: Bool {
//        return indexOfOneAndOnlyFaceUpCard == nil && !complete
//    }
//    
//    func flipNotMatchingCards() {
//        if indexOfOneAndOnlyFaceUpCard != nil { return }
//        
//        for index in cards.indices {
//            let card = cards[index]
//            if !card.isMatched, card.isFaceUp {
//                cards[index].isFaceUp = false
//            }
//        }
//    }
//    
//    var complete: Bool {
//        for card in cards {
//            if !card.isMatched { return false }
//        }
//        return true
//    }
//    
//    init(numberOfPairsOfCards: Int) {
//        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)) : You must have at least one pair of cards")
//		self.numberOfPairsOfCards = numberOfPairsOfCards
//        for _ in 1...numberOfPairsOfCards {
//            let card = Card()
//            cards += [card, card]
//        }
//		level = Options.sharedOptions.gameLevel
//       // shuffleCards(times: 2 * numberOfPairsOfCards)
//    }
//	
//	func moveToNextLevel() {
//		level = level + 1
//		Options.sharedOptions.gameLevel = level
//	}
//    
//    func restart() {
//        for index in cards.indices {
//            cards[index].isFaceUp = false
//            cards[index].isMatched = false
//        }
//        
//       // shuffleCards(times: cards.count)
//    }
//    
////   func shuffleCards(times: Int) {
////        for _ in 0...times {
////             let firstRandomIndex = cards.count.arc4Random
////            let secondRandomIndex = cards.count.arc4Random
////            cards.swapAt(firstRandomIndex, secondRandomIndex)
////        }
////    }
////}
//
//extension Collection {
//    var oneAndOnly: Element? {
//        return count == 1 ? first : nil
//    }
//}
