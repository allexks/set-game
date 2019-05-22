//
//  Int+repetitionsOf.swift
//  Set
//
//  Created by Aleksandar Ignatov on 22.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

extension Int {
  /// Repeat a procedure that many number of times
  ///
  /// - Parameter closure: The procedure to be repeated
  func repetitions(of closure: () -> Void) {
    for _ in 1...self {
      closure()
    }
  }
}
