//
//  SCacheManager.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import Foundation

struct SCMError: Error {
  enum ErrorKind {
    case fileWriteError
    case fileDeletionError
    case noUserId
  }

  let kind: ErrorKind
  var localizedDescription: String
}

final class SCacheManager {
  static let shared = SCacheManager()
  private let fileManager = FileManager.default

  private init() {}

  func cacheSchedule(_ data: [SScheduleDay], weekOffset: Int) throws {
    let fileName = SDefaults.filePrefix(for: .student)
    guard let userId = SDefaults.studentId else {
      throw SCMError(kind: .noUserId, localizedDescription: "No user ID specified")
    }

    let path = "\(fileName)\(userId)\(weekOffset)"

    do {
      if let url = getFileUrl(for: path) {
        let expirationDate = STimeManager.shared.getNextWeekDay()
        let cacheItem = SCacheItem(data: data, expires: expirationDate)
        let jsonData = try JSONEncoder().encode(cacheItem)
        try jsonData.write(to: url, options: .atomic)
      }
    } catch let error {
      throw SCMError(kind: .fileWriteError, localizedDescription: error.localizedDescription)
    }
  }

  func retrieveSchedule(weekOffset: Int) -> [SScheduleDay]? {
    let fileName = SDefaults.filePrefix(for: .student)
    guard let userId = SDefaults.studentId else {
      return nil
    }

    let path = "\(fileName)\(userId)\(weekOffset)"

    guard let url = getFileUrl(for: path) else { return nil }

    if fileManager.fileExists(atPath: url.path) {
      do {
        let jsonData = try Data(contentsOf: url)
        let cacheItem = try JSONDecoder().decode(SCacheItem.self, from: jsonData)
        if STimeManager.shared.validateCache(expirationDate: cacheItem.expirationDate) {
          return cacheItem.data
        }
      } catch {
        return nil
      }
    }

    return nil
  }

  func clearCache() throws {
    let fileNamePrefixes = [
      SDefaults.filePrefix(for: .student),
      SDefaults.filePrefix(for: .building),
      SDefaults.filePrefix(for: .employee)
    ]

    if let directory = getRootUrl() {
      do {
        let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.nameKey])
        for file in files {
          for fileNamePrefix in fileNamePrefixes {
            if file.lastPathComponent.hasPrefix(fileNamePrefix) {
              try fileManager.removeItem(at: file)
            }
          }
        }
      } catch let error {
        throw SCMError(kind: .fileDeletionError, localizedDescription: error.localizedDescription)
      }
    }
  }

  func cacheBuildings(_ data: [SBuilding]) throws {
    do {
      let fileName = SDefaults.filePrefix(for: .building)
      if let url = getFileUrl(for: fileName) {
        let jsonData = try JSONEncoder().encode(data)
        try jsonData.write(to: url, options: .atomic)
      }
    } catch let error {
      throw SCMError(kind: .fileWriteError, localizedDescription: error.localizedDescription)
    }
  }

  func retrieveBuildings() -> [SBuilding]? {
    let fileName = SDefaults.filePrefix(for: .building)
    if let url = getFileUrl(for: fileName) {
      if fileManager.fileExists(atPath: url.path) {
        do {
          let jsonData = try Data(contentsOf: url)
          let data = try JSONDecoder().decode([SBuilding].self, from: jsonData)
          return data
        } catch {
          return nil
        }
      }
    }

    return nil
  }

  func cacheEmployee(id: Int, _ data: SEmployee) throws {
    do {
      let filePrefix = SDefaults.filePrefix(for: .employee)
      let fileName = "\(filePrefix)\(id)"
      if let url = getFileUrl(for: fileName) {
        let jsonData = try JSONEncoder().encode(data)
        try jsonData.write(to: url, options: .atomic)
      }
    } catch let error {
      throw SCMError(kind: .fileWriteError, localizedDescription: error.localizedDescription)
    }
  }

  func retrieveEmployee(id: Int) -> SEmployee? {
    let filePrefix = SDefaults.filePrefix(for: .employee)
    let fileName = "\(filePrefix)\(id)"

    if let url = getFileUrl(for: fileName) {
      if fileManager.fileExists(atPath: url.path) {
        do {
          let jsonData = try Data(contentsOf: url)
          let data = try JSONDecoder().decode(SEmployee.self, from: jsonData)
          return data
        } catch {
          return nil
        }
      }
    }

    return nil
  }

  private func getFileUrl(for fileName: String) -> URL? {
    if let url = getRootUrl() {
      do {
        if !fileManager.fileExists(atPath: url.path) {
          try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
        }
      } catch {
        return nil
      }
      return url.appendingPathComponent(fileName, isDirectory: false)
    } else {
      return nil
    }
  }

  private func getRootUrl() -> URL? {
    let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
    return urls.first
  }
}
