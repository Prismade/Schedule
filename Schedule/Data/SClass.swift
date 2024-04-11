//
//  SClass.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

class SClass: Codable, Comparable {
  let cellId: Int? // Probably will be unused or deleted soon
  let groupId: Int
  let subgroup: Int
  let subject: String
  let kind: String
  let number: Int
  let weekDay: Int
  let building: String
  let room: String
  let special: String
  let groupTitle: String
  let employeeId: Int?
  let patronymic: String
  let firstName: String
  let lastName: String
  var employeeNameDesigned: String {
    guard firstName != "", lastName != "", patronymic != "" else { return "" }
    return "\(lastName) \(firstName.first!).\(patronymic.first!)."
  }
  var fullEmployeeNameDesigned: String {
    guard firstName != "", lastName != "", patronymic != "" else { return "" }
    return "\(lastName) \(firstName) \(patronymic)"
  }
  var groupTitleDesigned: String {
    return "\(groupTitle)"
  }
  var locationDesigned: String {
    return "\(building) корпус, ауд. \(room)"
  }
  var location: String {
    return "\(building)-\(room)"
  }

  enum CodingKeys: String, CodingKey {
    case cellId = "id_cell"
    case groupId = "idGruop"
    case subgroup = "NumberSubGruop"
    case subject = "TitleSubject"
    case kind = "TypeLesson"
    case number = "NumberLesson"
    case weekDay = "DayWeek"
    case building = "Korpus"
    case room = "NumberRoom"
    case special
    case groupTitle = "title"
    case employeeId = "employee_id"
    case patronymic = "SecondName"
    case firstName = "Name"
    case lastName = "Family"
  }

  init(cellId: Int?, groupId: Int, subgroup: Int, subject: String, kind: String, number: Int, weekDay: Int, building: String, room: String, special: String, groupTitle: String, employeeId: Int?, patronymic: String, firstName: String, lastName: String) {
    self.cellId = cellId
    self.groupId = groupId
    self.subgroup = subgroup
    self.subject = subject
    self.kind = kind
    self.number = number
    self.weekDay = weekDay
    self.building = building
    self.room = room
    self.special = special
    self.groupTitle = groupTitle
    self.employeeId = employeeId
    self.patronymic = patronymic
    self.firstName = firstName
    self.lastName = lastName
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    cellId = try? container.decode(Int.self, forKey: .cellId)
    groupId = try container.decode(Int.self, forKey: .groupId)
    subgroup = try container.decode(Int.self, forKey: .subgroup)
    subject = try container.decode(String.self, forKey: .subject)
    kind = try container.decode(String.self, forKey: .kind)
    number = try container.decode(Int.self, forKey: .number)
    weekDay = try container.decode(Int.self, forKey: .weekDay)
    building = try container.decode(String.self, forKey: .building)
    room = try container.decode(String.self, forKey: .room)
    special = try container.decode(String.self, forKey: .special)
    groupTitle = try container.decode(String.self, forKey: .groupTitle)
    employeeId = try? container.decode(Int.self, forKey: .employeeId)
    patronymic = try container.decode(String.self, forKey: .patronymic)
    firstName = try container.decode(String.self, forKey: .firstName)
    lastName = try container.decode(String.self, forKey: .lastName)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(groupId, forKey: .groupId)
    try container.encode(subgroup, forKey: .subgroup)
    try container.encode(subject, forKey: .subject)
    try container.encode(kind, forKey: .kind)
    try container.encode(number, forKey: .number)
    try container.encode(weekDay, forKey: .weekDay)
    try container.encode(building, forKey: .building)
    try container.encode(room, forKey: .room)
    try container.encode(special, forKey: .special)
    try container.encode(groupTitle, forKey: .groupTitle)
    if let employeeId = employeeId {
      try container.encode(employeeId, forKey: .employeeId)
    }
    try container.encode(patronymic, forKey: .patronymic)
    try container.encode(firstName, forKey: .firstName)
    try container.encode(lastName, forKey: .lastName)
  }

  static func < (lhs: SClass, rhs: SClass) -> Bool {
    if lhs.weekDay != rhs.weekDay {
      return lhs.weekDay < rhs.weekDay
    } else {
      return lhs.number < rhs.number
    }
  }

  static func == (lhs: SClass, rhs: SClass) -> Bool {
    if lhs.weekDay == rhs.weekDay {
      return lhs.number == rhs.number
    }

    return false
  }
}
