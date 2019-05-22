//
//  String+repeated.swift
//  Set
//
//  Created by Aleksandar Ignatov on 22.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

extension String {
  mutating func repeatSelf(numberOfTimes: Int) {
    guard numberOfTimes > 1 else { return }
    self = self.repeated(numberOfTimes: numberOfTimes)
  }
  
  func repeated(numberOfTimes: Int) -> String {
    guard numberOfTimes > 1 else { return self }
    
    var result = ""
    numberOfTimes.repetitions {
      result += self
    }
    return result
  }
}
