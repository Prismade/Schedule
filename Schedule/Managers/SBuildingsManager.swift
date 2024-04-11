//
//  SBuildingsManager.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

final class SBuildingsManager {
  static let shared = SBuildingsManager()
  private var buildings = [SBuilding]()

  private init() {}

  func setCoordinates(for building: Int, completion: @escaping (Double?, Double?) -> Void) {
    if buildings.count == 0 {
      if let data = SCacheManager.shared.retrieveBuildings() {
        buildings = data
        if building > 0 {
          completion(buildings[building - 1].coord[0], buildings[building - 1].coord[1])
        } else {
          completion(nil, nil)
        }
      } else {
        Task {
          do {
            let buildingsData: SBuildingData = try await NetworkWorker().data(from: Oreluniver.buildings)
            self.buildings = buildingsData.corpusData
            if (building - 1) < self.buildings.count {
              await MainActor.run {
                if building > 0 {
                  completion(
                    self.buildings[building - 1].coord[0],
                    self.buildings[building - 1].coord[1])
                } else {
                  completion(nil, nil)
                }
              }
            }
            try SCacheManager.shared.cacheBuildings(self.buildings)
          } catch {
            return
          }
        }
      }
    } else {
      if building > 0 {
        completion(buildings[building - 1].coord[0], buildings[building - 1].coord[1])
      } else {
        completion(nil, nil)
      }
    }
  }
}
