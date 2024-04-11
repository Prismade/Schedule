//
//  SSchedulePlaceholderView.swift
//  Schedule
//
//  Created by Egor Molchanov on 05.06.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit

final class SNibSchedulePlaceholderView: UIView {
  @IBOutlet weak var message: UILabel!

  static func loadFromNib() -> SNibSchedulePlaceholderView {
    let bundle = Bundle(for: self)
    let nib = UINib(nibName: "SSchedulePlaceholderView", bundle: bundle)
    let allViewsFromNib = nib.instantiate(withOwner: nil, options: nil)
    let schedulePlaceholder = allViewsFromNib.first! as! SNibSchedulePlaceholderView
    return schedulePlaceholder
  }
}

@IBDesignable
final class SSchedulePlaceholderView: UIView {
  var view: SNibSchedulePlaceholderView
  var didInstantiate: Bool = false
  var message: String = "Message" {
    didSet {
      view.message.text = message
    }
  }

  override init(frame: CGRect) {
    view = SNibSchedulePlaceholderView.loadFromNib()
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    view = SNibSchedulePlaceholderView.loadFromNib()
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
