//
//  SCourseSelectionTableViewController.swift
//  Schedule
//
//  Created by Egor Molchanov on 29.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit

final class SCourseSelectionTableViewController: UITableViewController {
  private lazy var cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(onCancelButtonTap))

  @objc
  private func onCancelButtonTap() {
    navigationController?.dismiss(animated: true) {
      NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
    }
  }

  let reuseIdentifier = "CourseTableCell"
  var needCancelButton = true
  var division: Int!
  var selectedCourse: Int!
  var data = [SCourse]()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("choose-course", comment: "")
    navigationItem.rightBarButtonItem = cancelButton

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

    if !needCancelButton {
      cancelButton.isEnabled = false
    }

    clearsSelectionOnViewWillAppear = false

    updateData()
  }

  @objc func refresh(_ sender: UIRefreshControl) {
    refreshControl?.beginRefreshing()
    updateData()
  }

  func updateData() {
    Task { [weak self] in
      guard let self else { return }
      do {
        let courses: [SCourse] = try await NetworkWorker().data(from: Oreluniver.courses(division: division))
        await MainActor.run {
          self.data = courses
          self.refreshControl?.endRefreshing()
          self.tableView.reloadData()
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  // MARK: - UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
    }
    cell!.textLabel?.text = String(data[indexPath.row].course)

    return cell!
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedCourse = data[indexPath.row].course
    let viewController = SGroupSelectionTableViewController(style: .plain)
    viewController.division = division
    viewController.course = selectedCourse
    viewController.needCancelButton = needCancelButton
    navigationController?.pushViewController(viewController, animated: true)
  }
}
