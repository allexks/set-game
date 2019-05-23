//
//  Card.swift
//  Set
//
//  Created by Aleksandar Ignatov on 21.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

struct Card: Equatable, Hashable {
  let number: Number
  let shape: Shape
  let shading: Shading
  let color: Color
}

extension Card {
  enum Number: Int, CaseIterable {
    case one = 1, two, three
  }
  
  enum Shape: CaseIterable {
    case diamond, squiggle, stadium
  }
  
  enum Shading: CaseIterable {
    case solid, striped, open
  }
  
  enum Color: CaseIterable {
    case red, green, purple
  }
}
