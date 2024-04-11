//
//  MainTabBarController.swift
//  Schedule
//
//  Created by Egor Molchanov on 11.04.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scheduleViewController = UINavigationController(rootViewController: StudentScheduleViewController())
    scheduleViewController.tabBarItem = UITabBarItem(
      title: NSLocalizedString("student", comment: ""),
      image: UIImage(systemName: "person.fill"),
      tag: 0)

    let examsViewController = UINavigationController(rootViewController: ExamsTableViewController(style: .grouped))
    examsViewController.tabBarItem = UITabBarItem(
      title: NSLocalizedString("exams", comment: ""),
      image: UIImage(systemName: "doc.text.fill"),
      tag: 1)

    viewControllers = [scheduleViewController, examsViewController]
  }
}
