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
  
  private(set) var availableCards: [Card] = []
  private(set) var discardedCards: [Card] = []
  private(set) var selectedCards: [Card] = [] {
    didSet {
      delegate?.updateSelectedCards()
    }
  }
  
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
        delegate?.foundSet()
      } else {
        delegate?.foundMismatch()
      }
    }
  }
  
  func deselectCard(_ card: Card) {
    if let indexToRemove = selectedCards.firstIndex(of: card) {
      selectedCards.remove(at: indexToRemove)
    }
  }
  
  func dealThreeCards() {
    guard !deck.isEmpty else { return }
    
    3.repetitions {
      self.availableCards.append(self.deck.draw())
    }
  }
}
