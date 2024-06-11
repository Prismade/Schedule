//
//  ClassDetailsTextBuilder.swift
//  Schedule
//
//  Created by Egor Molchanov on 10.06.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class ClassDetailsTextBuilder {
  private let titleAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 20.0, weight: .semibold),
    .foregroundColor: UIColor.label,
    .paragraphStyle: { 
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let specialAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0),
    .foregroundColor: UIColor.label,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let kindAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0),
    .foregroundColor: UIColor.label,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let locationAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0),
    .foregroundColor: UIColor.label,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]
  private let teacherAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 17.0),
    .foregroundColor: UIColor.accent,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }(),
    .link: "teacher-details"
  ]
  private let timeAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 14.0, weight: .light),
    .foregroundColor: UIColor.secondaryLabel,
    .paragraphStyle: {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacing = 8.0
      return style
    }()
  ]

  func buildDetailsText(fromClassData classData: SClass) -> NSAttributedString {
    let text = NSMutableAttributedString()

    let subject = NSAttributedString(string: "\(classData.subject.replacingOccurrences(of: "\u{00A0}", with: " "))\n", attributes: titleAttributes)
    text.append(subject)

    if !classData.special.isEmpty {
      let special = NSAttributedString(string: "(\(classData.special.replacingOccurrences(of: "\u{00A0}", with: " ")))\n", attributes: specialAttributes)
      text.append(special)
    }

    let kind = NSAttributedString(string: "(\(classData.kind))\n", attributes: kindAttributes)
    text.append(kind)

    let location = NSAttributedString(string: "\(classData.location)\n", attributes: locationAttributes)
    text.append(location)

    let teacher = NSAttributedString(string: "\(classData.employeeNameDesigned)\n", attributes: teacherAttributes)
    text.append(teacher)

    if let timeBounds = STimeManager.shared.timetable[classData.number] {
      let time = NSAttributedString(string: "\(timeBounds.0)-\(timeBounds.1)", attributes: timeAttributes)
      text.append(time)
    }

    return text.copy() as! NSAttributedString
  }
}
