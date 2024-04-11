//
//  SScheduleDay.swift
//  Schedule
//
//  Created by Egor Molchanov on 18.06.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

final class SScheduleDay: Codable {
  let weekDay: SWeekDay
  var classes: [SClass]

  init(weekDay: SWeekDay, classes: [SClass]) {
    self.weekDay = weekDay
    self.classes = classes
  }
}
