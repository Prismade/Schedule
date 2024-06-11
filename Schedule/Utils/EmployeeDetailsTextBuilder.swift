//
//  EmployeeDetailsTextBuilder.swift
//  Schedule
//
//  Created by Egor Molchanov on 11.06.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class EmployeeDetailsTextBuilder {
  private let titleAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 20.0, weight: .semibold),
    .foregroundColor: UIColor.label,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let labelAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
    .foregroundColor: UIColor.label,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let genericAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0),
    .foregroundColor: UIColor.label,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let baselinkAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0),
    .foregroundColor: UIColor.accent,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]

  func buildDetailsText(fromEmployeeDetails teacherDetails: SEmployee) -> NSAttributedString {
    let text = NSMutableAttributedString()

    let name = NSAttributedString(string: "\(teacherDetails.name)\n", attributes: titleAttributes)
    text.append(name)

    let positionLabel = NSAttributedString(string: NSLocalizedString("position", comment: ""), attributes: labelAttributes)
    text.append(positionLabel)

    let positionText = NSAttributedString(string: "\(teacherDetails.allPositions)\n", attributes: genericAttributes)
    text.append(positionText)

    if let degree = teacherDetails.degree {
      let degreeTitle = NSAttributedString(string: NSLocalizedString("degree", comment: ""), attributes: labelAttributes)
      text.append(degreeTitle)

      let degreeText = NSAttributedString(string: "\(degree)\n", attributes: genericAttributes)
      text.append(degreeText)
    }

    if let rank = teacherDetails.rank {
      let rankTitle = NSAttributedString(string: NSLocalizedString("rank", comment: ""), attributes: labelAttributes)
      text.append(rankTitle)

      let rankText = NSAttributedString(string: "\(rank)\n", attributes: genericAttributes)
      text.append(rankText)
    }

    guard teacherDetails.contacts.address != nil || teacherDetails.contacts.email != nil || teacherDetails.contacts.phone != nil else { return text.copy() as! NSAttributedString }

    let contacts = NSAttributedString(string: "\(NSLocalizedString("contacts", comment: ""))\n", attributes: titleAttributes)
    text.append(contacts)

    if let address = teacherDetails.contacts.address {
      let addressText = NSAttributedString(string: "\(address)\n", attributes: genericAttributes)
      text.append(addressText)
    }

    if let phone = teacherDetails.contacts.phone {
      var linkAttributes = baselinkAttributes
      linkAttributes[.link] = URL(string: "tel:\(phone)") ?? phone
      let phoneText = NSAttributedString(string: "\(phone)\n", attributes: linkAttributes)
      text.append(phoneText)
    }

    if let email = teacherDetails.contacts.email {
      var linkAttributes = baselinkAttributes
      linkAttributes[.link] = URL(string: "mailto:\(email)") ?? email
      let emailText = NSAttributedString(string: email, attributes: linkAttributes)
      text.append(emailText)
    }

    return text.copy() as! NSAttributedString
  }
}
