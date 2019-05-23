//
//  SetGameDelegate.swift
//  Set
//
//  Created by Aleksandar Ignatov on 21.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

protocol SetGameDelegate: class {
  func foundSet()
  func foundMismatch()
  func deckGotEmpty()
  func updateScore(with newScore: Int)
  func updateSelectedCards()
  func gameOver()
}
