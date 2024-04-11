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

    guard
      let examsViewController = UIStoryboard(name: "ExamsSchedule", bundle: .main).instantiateInitialViewController()
    else {
      return
    }
    let scheduleViewController = UINavigationController(rootViewController: StudentScheduleViewController())
    viewControllers = [scheduleViewController, examsViewController]
  }
}
