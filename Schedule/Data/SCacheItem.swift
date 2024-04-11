//
//  SCacheItem.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

class SCacheItem: Codable {
  let data: [SScheduleDay]
  let expirationDate: Date
  
  init(data: [SScheduleDay], expires expirationDate: Date) {
    self.data = data
    self.expirationDate = expirationDate
  }
}
