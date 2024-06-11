//
//  SGroupSelectionTableViewController.swift
//  Schedule
//
//  Created by Egor Molchanov on 29.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit

final class SGroupSelectionTableViewController: SSearchableTableViewController {
  private lazy var cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(onFinishButtonTap))

  @objc
  private func onFinishButtonTap() {
    navigationController?.dismiss(animated: true) {
      NotificationCenter.default.post(name: Notification.Name("StudentSetupModalDismiss"), object: nil, userInfo: nil)
    }
  }

  var division: Int!
  var course: Int!
  var selectedGroup: SGroup!
  var needCancelButton = true
  var data = [SGroup]()
  var filteredData = [SGroup]()

  override func viewDidLoad() {
    super.viewDidLoad()
    reuseIdentifier = "DivisionTableCell"

    title = NSLocalizedString("choose-group", comment: "")
    navigationItem.rightBarButtonItem = cancelButton

    if !needCancelButton {
      cancelButton.isEnabled = false
    }

    updateData()
  }

  override func updateSearchResults(for searchController: UISearchController) {
    let searchResults = data
    let finalCompoundPredicate = getFinalCompoundPredicate()
    filteredData = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
    tableView.reloadData()
  }

  override func updateData() {
    Task { [weak self] in
      guard let self else { return }
      do {
        let groups: [SGroup] = try await NetworkWorker().data(from: Oreluniver.groups(division: division, course: course))
        await MainActor.run {
          self.data = groups
          self.refreshControl?.endRefreshing()
          self.tableView.reloadData()
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  override func fillCell(_ cell: inout UITableViewCell, at indexPath: IndexPath) {
    if isFiltering {
      cell.textLabel?.text = filteredData[indexPath.row].title
    } else {
      cell.textLabel?.text = data[indexPath.row].title
    }
  }

  override func findMatches(searchString: String) -> NSCompoundPredicate {
    var searchItemsPredicate = [NSPredicate]()

    let titleExpression = NSExpression(forKeyPath: SGroup.ExpressionKeys.title.rawValue)
    let codeExpression = NSExpression(forKeyPath: SGroup.ExpressionKeys.code.rawValue)
    let levelExpression = NSExpression(forKeyPath: SGroup.ExpressionKeys.level.rawValue)

    let searchStringExpression = NSExpression(forConstantValue: searchString)

    let titleSearchComparisonPredicate =
    NSComparisonPredicate(leftExpression: titleExpression,
                          rightExpression: searchStringExpression,
                          modifier: .direct,
                          type: .contains,
                          options: [.caseInsensitive, .diacriticInsensitive])
    let codeSearchComparisonPredicate =
    NSComparisonPredicate(leftExpression: codeExpression,
                          rightExpression: searchStringExpression,
                          modifier: .direct,
                          type: .contains,
                          options: [.caseInsensitive, .diacriticInsensitive])
    let levelSearchComparisonPredicate =
    NSComparisonPredicate(leftExpression: levelExpression,
                          rightExpression: searchStringExpression,
                          modifier: .direct,
                          type: .contains,
                          options: [.caseInsensitive, .diacriticInsensitive])

    searchItemsPredicate.append(titleSearchComparisonPredicate)
    searchItemsPredicate.append(codeSearchComparisonPredicate)
    searchItemsPredicate.append(levelSearchComparisonPredicate)

    return NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredData.count
    } else {
      return data.count
    }
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isFiltering {
      selectedGroup = filteredData[indexPath.row]
    } else {
      selectedGroup = data[indexPath.row]
    }

    navigationController?.dismiss(animated: true) {
      NotificationCenter.default.post(name: Notification.Name("StudentSetupModalDismiss"), object: nil, userInfo: ["UserId": self.selectedGroup.id, "UserName": self.selectedGroup.title])
    }
  }
}
