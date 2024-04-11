//
//  SGroup.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

class SGroup: NSObject, Decodable {
  @objc let title: String
  let id: Int
  @objc let code: String
  @objc let level: String

  enum CodingKeys: String, CodingKey {
    case title
    case id = "idgruop"
    case code = "Codedirection"
    case level = "levelEducation"
  }

  enum ExpressionKeys: String {
    case title
    case code
    case level
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    title = try container.decode(String.self, forKey: .title)
    id = try container.decode(Int.self, forKey: .id)
    code = try container.decode(String.self, forKey: .code)
    level = try container.decode(String.self, forKey: .level)
  }
}
