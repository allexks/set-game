//
//  ViewController.swift
//  Set
//
//  Created by Aleksandar Ignatov on 21.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController, SetGameDelegate {
  
  // MARK: - Outlets
  
  @IBOutlet var cardButtons: [UIButton]!
  @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var dealThreeCardsButton: UIButton!
  @IBOutlet weak var scoreLabel: UILabel!
  
  // MARK: - Properties
  
  private let initalNumberOfCards = 4 * 3
  private let cardShapesStrokeWidth = NSNumber(3.0)
  private let cardAlphaComponentForStripedCard = CGFloat(0.15)
  private let buttonsOutlineWidth = CGFloat(3.0)
  
  private var game: SetGame! {
    didSet {
      game?.delegate = self
    }
  }
  
  private var cardsForButton: [UIButton: Card] = [:]
  private var statusOfButton: [UIButton: CardButtonStatus] = [:]
  private var deckIsEmpty = false
  
  // MARK: - View Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    game = SetGame()
    
    (initalNumberOfCards / 3).repetitions {
      game.dealThreeCards()
    }
    
    for (i, button) in cardButtons.enumerated() {
      button.setTitle("", for: .normal)
      button.setAttributedTitle(NSAttributedString(string: ""), for: .normal)
      button.layer.cornerRadius = buttonHeightConstraint.constant / 4
      button.layer.borderWidth = buttonsOutlineWidth
      button.layer.borderColor = UIColor.clear.cgColor
      button.alpha = i < initalNumberOfCards ? 1 : 0
      statusOfButton[button] = i < initalNumberOfCards ? .notSelected : .unavailable
      cardsForButton[button] = nil
    }
    
    updateViews()
  }
  
  // MARK: - Actions
  
  @IBAction func onTapCardButton(_ sender: UIButton) {
    switch statusOfButton[sender]! {
    case .notSelected, .mismatched:
      selectButton(sender)
      game.selectCard(cardsForButton[sender]!)
      updateViews()
    case .selected:
      disselectButton(sender)
      game.disselectCard(cardsForButton[sender]!)
      updateViews()
    case .matched:
      removeMatched()
    default:
      break
    }
  }
  
  @IBAction func onTapDealThreeCardsButton(_ sender: UIButton) {
    dealThree()
  }
  
  // MARK: - Set Game Delegate
  
  func foundSet() {
    for card in game.selectedCards {
      let correspondingButton = cardsForButton.first { $1 == card }!.key
      markMatched(correspondingButton)
    }
    updateViews()
  }
  
  func foundMismatch() {
    for card in game.selectedCards {
      let correspondingButton = cardsForButton.first { $1 == card }!.key
      markMismatched(correspondingButton)
    }
    updateViews()
  }
  
  func deckGotEmpty() {
    dealThreeCardsButton.isHidden = true
    deckIsEmpty = true
  }
  
  func updateScore(with newScore: Int) {
    scoreLabel.text = "Score: \(newScore)"
  }
  
  func gameOver() {
    for button in cardButtons {
      statusOfButton[button] = .unavailable
    }
    updateViews()
  }
  
  // MARK: - Helpers
  
  private func selectButton(_ button: UIButton) {
    let mismatchedButtons = cardButtons.filter({ statusOfButton[$0] == .mismatched })
    for mbutton in mismatchedButtons {
      statusOfButton[mbutton] = .notSelected
    }
    statusOfButton[button] = .selected
  }
  
  private func disselectButton(_ button: UIButton) {
    statusOfButton[button] = .notSelected
  }
  
  private func markMatched(_ button: UIButton) {
    statusOfButton[button] = .matched
  }
  
  private func markMismatched(_ button: UIButton) {
    statusOfButton[button] = .mismatched
  }
  
  private func hideButton(_ button: UIButton) {
    cardsForButton[button] = nil
    statusOfButton[button] = .unavailable
    button.alpha = 0
  }
  
  private func unhideButton(_ button: UIButton) {
    statusOfButton[button] = .notSelected
    button.alpha = 1
  }
  
  private func dealThree() {
    game.dealThreeCards()
    updateViews()
  }
  
  private func removeMatched() {
    let matchedButtons = cardButtons.filter({ statusOfButton[$0] == .matched })
    
    for button in matchedButtons {
      hideButton(button)
    }
    
    if !deckIsEmpty {
      dealThree()
    } else {
      updateViews()
    }
  }
  
  private func updateViews() {
    for card in game.availableCards {
      if !cardsForButton.values.contains(card) {
        let pickAvailableButton = cardButtons.first(where: { cardsForButton[$0] == nil })!
        cardsForButton[pickAvailableButton] = card
        statusOfButton[pickAvailableButton] = .notSelected
      }
    }
    
    for button in cardButtons.filter({ statusOfButton[$0] != .unavailable }) {
      renderCard(on: button)
    }
    
    if cardButtons.filter({ statusOfButton[$0]! == .unavailable }).isEmpty {
      // no more space for cards in the UI => disable deal cards button
      dealThreeCardsButton.isHidden = true
    }
  }
  
  private func renderCard(on button: UIButton) {
    let card = cardsForButton[button]!
    
    var cardText: String
    switch card.shape {
    case .diamond:
      cardText = "▲"
    case .squiggle:
      cardText = "●"
    case .stadium:
      cardText = "■"
    }
    
    cardText.repeatSelf(numberOfTimes: card.number.rawValue)
    
    var textAttributes: [NSAttributedString.Key: Any] = [:]
    
    var textColor: UIColor
    switch card.color {
    case .green:
      textColor = .green
    case .purple:
      textColor = .blue
    case .red:
      textColor = .red
    }
    
    switch card.shading {
    case .open:
      textAttributes[.foregroundColor] = textColor
      textAttributes[.strokeWidth] = cardShapesStrokeWidth
    case .solid:
      textAttributes[.foregroundColor] = textColor
      textAttributes[.strokeWidth] = -1
    case .striped:
      textAttributes[.foregroundColor] = textColor.withAlphaComponent(cardAlphaComponentForStripedCard)
      textAttributes[.strokeWidth] = -1
    }
    
    button.setAttributedTitle(
      NSAttributedString(
        string: cardText,
        attributes: textAttributes
      ),
      for: .normal
    )
    
    button.layer.borderColor = statusOfButton[button]?.borderColor
  }
}

extension SetGameViewController {
  private enum CardButtonStatus {
    case notSelected, selected, matched, mismatched, unavailable
  
    var borderColor: CGColor {
      switch self {
      case .notSelected, .unavailable:
        return UIColor.clear.cgColor
      case .selected:
        return UIColor.blue.cgColor
      case .matched:
        return UIColor.green.cgColor
      case .mismatched:
        return UIColor.red.cgColor
      }
    }
  }
}

