//
//  Deck.swift
//  Set
//
//  Created by Aleksandar Ignatov on 21.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

class Deck {
  var cards: [Card] = []
  
  var isEmpty: Bool {
    return cards.isEmpty
  }
  
  init(randomize: Bool = true) {
    for number in Card.Number.allCases {
      for shape in Card.Shape.allCases {
        for shading in Card.Shading.allCases {
          for color in Card.Color.allCases {
            cards.append(Card(number: number, shape: shape, shading: shading, color: color))
          }
        }
      }
    }
    
    if randomize {
      cards.shuffle()
    }
  }
  
  func draw() -> Card {
    return cards.removeLast()
  }
}
