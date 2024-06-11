//
//  EmployeeDataScraper.swift
//  Schedule
//
//  Created by Egor Molchanov on 11.06.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation
import SwiftSoup

final class EmployeeDataScraper {
  func scrapeData(fromHTML data: Data, forEmployeeID employeeID: Int) throws -> SEmployee? {
    guard let html = String(data: data, encoding: .windowsCP1251) else { return nil }
    var name = ""
    var image: String?
    var positions: [String] = []
    var degree: String?
    var rank: String?
    var address: String?
    var phone: String?
    var email: String?

    let document = try SwiftSoup.parse(html)

    // nil here
    guard let nameElement = try document.select("h1.center").first() else { return nil }
    name = try nameElement.text()

    let imgElement = try document.select("img.img-circle").first()!
    let imgString = try imgElement.attr("src")
    if imgString != "/img/employee/no_picture.png" {
      image = imgString
    }

    let positionElements = try document.select("p.profile-value[itemprop=post]")
    positions = try positionElements.map { try $0.text() }

    if let degreeElement = try document.select("p.profile-value[itemprop=degree]").first() {
      degree = try degreeElement.text()
    }

    if let rankElement = try document.select("p.profile-value[itemprop=academStat]").first() {
      rank = try rankElement.text()
    }

    let contactsElements = try document.select("#contacts > p")

    let addressElement = try contactsElements.array()[0].getElementsByTag("span").first()!
    let addressElementText = try addressElement.text()
    if addressElementText != "" {
      address = addressElementText
    }

    let phoneElement = try contactsElements.array()[1].getElementsByTag("span").first()!
    let phoneElementText = try phoneElement.text()
    if phoneElementText != "" {
      phone = phoneElementText
    }

    let emailElement = try contactsElements.array()[2].getElementsByTag("span").first()!
    let emailElementText = try emailElement.text()
    if emailElementText != "" {
      email = emailElementText
    }

    let employee = SEmployee(
      id: employeeID,
      name: name,
      image: image,
      position: positions,
      degree: degree,
      rank: rank,
      contacts: SEmployee.SContacts(
        address: address,
        email: email,
        phone: phone
      )
    )

    return employee
  }
}
