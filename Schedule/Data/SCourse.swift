//
//  SCourse.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

class SCourse: Decodable {
  let course: Int

  enum CodingKeys: String, CodingKey {
    case course = "kurs"
  }

  init(decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    course = try container.decode(Int.self, forKey: .course)
  }
}
