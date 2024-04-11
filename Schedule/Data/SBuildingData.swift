//
//  SBuilding.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

final class SBuilding: Codable {
  let title: String
  let coord: [Double]
  let address: String
  let img: String
}

final class SBuildingData: Codable {
  let corpusData: [SBuilding]
}
