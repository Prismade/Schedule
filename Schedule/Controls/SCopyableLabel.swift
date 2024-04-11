//
//  SCopyableLabel.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit

final class SCopyableLabel: UILabel {
  override var canBecomeFirstResponder: Bool {
    get { return true }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    isUserInteractionEnabled = true
    addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
  }

  override func copy(_ sender: Any?) {
    UIPasteboard.general.string = text
    UIMenuController.shared.hideMenu(from: self)
  }

  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return (action == #selector(copy(_:)))
  }

  @objc private func showMenu(sender: Any?) {
    becomeFirstResponder()
    let menu = UIMenuController.shared
    if !menu.isMenuVisible {
      let rect = self.textRect(forBounds: self.bounds, limitedToNumberOfLines: -1)
      menu.showMenu(from: self, rect: rect)
    }
  }
}
