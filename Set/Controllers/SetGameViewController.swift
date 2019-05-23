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
    game.selectCard(cardsForButton[sender]!)
  }
  
  @IBAction func onTapDealThreeCardsButton(_ sender: UIButton) {
    dealThree()
  }
  
  // MARK: - Set Game Delegate
  
  func foundSet() {
    for card in game.selectedCards {
      let correspondingButton = cardsForButton.first { $1 == card }!.key
      statusOfButton[correspondingButton] = .matched
    }
    updateViews()
    if !deckIsEmpty {
      dealThreeCardsButton.isHidden = false
    }
  }
  
  func foundMismatch() {
    for card in game.selectedCards {
      let correspondingButton = cardsForButton.first { $1 == card }!.key
      statusOfButton[correspondingButton] = .mismatched
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
  
  func updateSelectedCards() {
    updateViews()
  }
  
  // MARK: - Helpers
  
  private func dealThree() {
    game.dealThreeCards()
    updateViews()
  }
  
  private func hideButton(_ button: UIButton) {
    cardsForButton[button] = nil
    statusOfButton[button] = .unavailable
    button.alpha = 0
  }
  
  private func updateViews() {
    for card in game.availableCards.filter({ !cardsForButton.values.contains($0) }) {
      // pick a button for the new cards
      let pickAvailableButton = cardButtons.first(where: { cardsForButton[$0] == nil })!
      cardsForButton[pickAvailableButton] = card
      statusOfButton[pickAvailableButton] = .notSelected
    }
    
    for card in game.selectedCards {
      // mark selected cards
      let correspondingButton = cardButtons.first(where: { cardsForButton[$0] == card })!
      if statusOfButton[correspondingButton]! == .notSelected {
        statusOfButton[correspondingButton] = .selected
      }
    }
    
    for button in cardButtons {
      if let card = cardsForButton[button], !game.selectedCards.contains(card) {
        // update deselected and removed cards
        if game.availableCards.contains(card) {
          statusOfButton[button] = .notSelected
        } else {
          statusOfButton[button] = .unavailable
        }
      }
      renderCard(on: button)
    }
    
    if cardButtons.filter({ statusOfButton[$0]! == .unavailable }).isEmpty {
      // no more space for cards in the UI => disable deal cards button
      dealThreeCardsButton.isHidden = true
    } else if !deckIsEmpty{
      dealThreeCardsButton.isHidden = false
    }
  }
  
  private func renderCard(on button: UIButton) {
    guard let cardStatus = statusOfButton[button],
      cardStatus != .unavailable,
      let card = cardsForButton[button]
    else {
      hideButton(button)
      return
    }
    
    button.layer.borderColor = cardStatus.borderColor

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
    
    button.alpha = 1
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

