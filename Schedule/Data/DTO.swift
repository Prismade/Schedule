//
//  DTO.swift
//  Schedule
//
//  Created by Egor Molchanov on 09.05.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation
import UIKit

struct UniversityClass {
  enum Kind {
    case lecture, practicum, laboratory
    init?(rawValue: String) {
      if rawValue.contains("лек") {
        self = .lecture
      } else if rawValue.contains("пр") {
        self = .practicum
      } else if rawValue.contains("лаб") {
        self = .laboratory
      } else {
        return nil
      }
    }
  }
  let subject: String
  let special: String?
  let subgroupNumber: Int?
  let kind: Kind
  let date: Date
  let teacherID: Int
  let building: UniversityBuilding
}

struct UniversityBuilding {
  let number: Int
  let title: String
  let address: String
  let coords: (lat: Double, long: Double)
  let imageURL: URL
}

struct UniversityTeacher {
  let identifier: Int
  let name: String
  let imageURL: URL
  let position: String
  let degree: String?
  let rank: String?
  let address: String?
  let email: String?
  let phone: String?
}

struct TextStyle {
  let font: UIFont
  let color: UIColor
  var attributes: [NSAttributedString.Key: Any] {
    [.font: font, .foregroundColor: color]
  }
}

protocol DetailsFormatter {
  var attributedString: NSAttributedString { get }
  var string: String { get }
}

//struct ClassDetailsFormatter: DetailsFormatter {
//  enum Stylesheet {
//    static var title: TextStyle {
//      TextStyle(font: .systemFont(ofSize: 30.0, weight: .semibold), color: .label)
//    }
//    static var subtitle: TextStyle {
//      TextStyle(font: .systemFont(ofSize: 22.0, weight: .semibold), color: .label)
//    }
//    static var text: TextStyle {
//      TextStyle(font: .systemFont(ofSize: 17.0), color: .label)
//    }
//    static var link: TextStyle {
//      TextStyle(font: .systemFont(ofSize: 17.0), color: .accent)
//    }
//  }
//
//  var attributedString: NSAttributedString {
//    return NSAttributedString()
//  }
//  var string: String {
//    return ""
//  }
//
//  let subject: String
//  let special: String?
//  let subgroup: String?
//  let kind: String
//  let location: String
//  let teacher: String
//
//  init(universityClass: UniversityClass) {
//    self.subject = universityClass.subject
//  }
//}
//
//final class TeacherDetailsFormatter {
//
//}
