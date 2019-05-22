//
//  SetGame.swift
//  Set
//
//  Created by Aleksandar Ignatov on 21.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

class SetGame {
  // MARK: - Properties
  private let deck = Deck()
  private(set) var score = 0 {
    didSet {
      delegate?.updateScore(with: score)
    }
  }
  
  private let scoreRules: ScoreRules = .easy
  
  private(set) var availableCards: [Card] = []
  private(set) var discardedCards: [Card] = []
  private(set) var selectedCards: [Card] = []
  
  weak var delegate: SetGameDelegate?
  
  // MARK: - Methods
  
  static func isSet(_ cardsArr: [Card]) -> Bool {
    guard cardsArr.count == 3 else {
      return false
    }
    
    let numbers = Set(arrayLiteral: cardsArr.map{ $0.number })
    let shapes = Set(arrayLiteral: cardsArr.map{ $0.shape })
    let shadings = Set(arrayLiteral: cardsArr.map{ $0.shading })
    let colors = Set(arrayLiteral: cardsArr.map{ $0.color })
    
    return numbers.count == Card.Number.allCases.count
        && shapes.count == Card.Shape.allCases.count
        && shadings.count == Card.Shading.allCases.count
        && colors.count == Card.Color.allCases.count
  }
  
  
  func selectCard(_ card: Card) {
    guard !selectedCards.contains(card) else {
      return
    }
    
    if selectedCards.count == 3 {
      selectedCards = []
    }
    
    selectedCards.append(card)
    
    if selectedCards.count == 3 {
      if SetGame.isSet(selectedCards) {
        score = score + scoreRules.updateOnMatch
        delegate?.foundSet()
        removeMatchedCards()
      } else {
        score = score + scoreRules.updateOnMismatch
        delegate?.foundMismatch()
      }
    }
  }
  
  func disselectCard(_ card: Card) {
    if let indexToRemove = selectedCards.firstIndex(of: card) {
      selectedCards.remove(at: indexToRemove)
    }
  }
  
  func dealThreeCards() {
    guard !deck.isEmpty else { return }
    
    3.repetitions {
      self.availableCards.append(self.deck.draw())
    }
    
    if let scoreChange = scoreRules.updateOnDealingThreeCards {
      score = score + scoreChange
    }
    
    if deck.isEmpty {
      delegate?.deckGotEmpty()
    }
  }
  
  private func removeMatchedCards() {
    availableCards = availableCards.filter({ !selectedCards.contains($0) })
    discardedCards = discardedCards + selectedCards
    
    if availableCards.count == 0 && deck.isEmpty {
      delegate?.gameOver()
    }
  }
}

extension SetGame {
  enum ScoreRules {
    case easy, medium, hard
    case custom(updateOnMatch: Int, updateOnMismatch: Int, updateOnDealingThreeCards: Int?)
    
    var updateOnMatch: Int {
      switch self {
      case .easy:
        return +20
      case .medium:
        return +10
      case .hard:
        return +5
      case .custom(let x, _, _):
        return x
      }
    }
    
    var updateOnMismatch: Int {
      switch self {
      case .easy:
        return -5
      case .medium:
        return -10
      case .hard:
        return -20
      case .custom(_, let x, _):
        return x
      }
    }
    
    var updateOnDealingThreeCards: Int? {
      switch self {
      case .easy, .medium:
        return nil
      case .hard:
        return -5
      case .custom(_, _, let x):
        return x
      }
    }
  }
}
