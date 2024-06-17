//
//  StudentScheduleViewController.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

final class StudentScheduleViewController: UIViewController {
  struct SelectedClass {
    let day: SWeekDay
    let number: Int
  }

  private lazy var calendar: SCalendarView = {
    let view = SCalendarView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var schedule: SScheduleView = {
    let view = SScheduleView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var placeholder: SSchedulePlaceholderView = {
    let view = SSchedulePlaceholderView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var groupButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = NSLocalizedString("group", comment: "")
    configuration.image = UIImage(systemName: "chevron.right")?.applyingSymbolConfiguration(.init(scale: .small))
    configuration.imagePlacement = .trailing
    configuration.cornerStyle = .capsule
    configuration.imagePadding = 8.0
    let button = UIButton(configuration: configuration)
    button.addTarget(self, action: #selector(handleGroupButtonTap(_:)), for: .touchUpInside)
    return button
  }()

  private var lastSelectedClass: SelectedClass? = nil
  private lazy var calendarSelectionViewController = UINavigationController()
  private let scheduleSource = SScheduleData(for: .student)

  @objc
  private func handleGroupButtonTap(_ sender: UIButton) {
    let viewController = SDivisionSelectionTableViewController(style: .plain)
    let navigationController = UINavigationController(rootViewController: viewController)
    present(navigationController, animated: true)
  }

  override func loadView() {
    view = UIView()

    view.addSubview(calendar)
    NSLayoutConstraint.activate([
      calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      calendar.heightAnchor.constraint(equalToConstant: 92.0)
    ])

    view.addSubview(schedule)
    NSLayoutConstraint.activate([
      schedule.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      schedule.topAnchor.constraint(equalTo: calendar.bottomAnchor),
      schedule.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      schedule.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    view.addSubview(placeholder)
    NSLayoutConstraint.activate([
      placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      placeholder.topAnchor.constraint(equalTo: view.topAnchor),
      placeholder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      placeholder.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "calendar.badge.plus"),
      style: .plain,
      target: self,
      action: #selector(calendarExportButtonTapped(_:)))
    navigationItem.titleView = groupButton
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(onModalDismiss(_:)), name: Notification.Name("StudentSetupModalDismiss"), object: nil)

    scheduleSource.userId = SDefaults.studentId
    groupButton.configuration?.title = SDefaults.studentName
    scheduleSource.didFinishDataUpdate = { error in
      if let err = error {
        debugPrint(err.localizedDescription)
      } else {
        self.schedule.reloadData()
      }
    }

    calendar.weekDaysForWeekOffset = { weekOffset in
      let weekDates = STimeManager.shared.getDates(for: weekOffset)
      return weekDates
    }

    calendar.dayWasSelected = { calendar, indexPath in
      self.schedule.scrollToDay(indexPath.day)
    }

    calendar.weekWasChanged = { calendar, newWeekOffset in
      self.updateSchedule(newWeekOffset: newWeekOffset)
    }

    schedule.dayWasChanged = { schedule, day in
      self.calendar.selectedDay = day
    }

    schedule.weekWasChanged = { schedule, direction in
      self.scheduleSource.schedule.removeAll()
      switch direction {
      case .back:
        self.calendar.weekOffset -= 1
        self.calendar.selectedDay = .saturday
      case .forward:
        self.calendar.weekOffset += 1
        self.calendar.selectedDay = .monday
      }

      self.updateSchedule(newWeekOffset: self.calendar.weekOffset)
    }

    schedule.tableViewDataSource = self
    schedule.tableViewDelegate = self

    placeholder.message = NSLocalizedString("need-group", comment: "")
    if SDefaults.studentId != nil {
      placeholder.isHidden = true
      updateSchedule()
    } else {
      placeholder.isHidden = false
    }
  }

  override func viewDidLayoutSubviews() {
    let weekDay = STimeManager.shared.getCurrentWeekday()
    if weekDay == .sunday {
      calendar.instantiateView(for: .monday)
      schedule.instantiateView(for: .monday)
    } else {
      calendar.instantiateView(for: weekDay)
      schedule.instantiateView(for: weekDay)
    }
  }

  @objc
  private func calendarExportButtonTapped(_ sender: UIBarButtonItem) {
    switch SExportManager.shared.authStatus {
    case .notDetermined:
      SExportManager.shared.requestPermission { [unowned self] authorized, error in
        if authorized {
          DispatchQueue.main.async {
            self.chooseCalendar()
          }
        }
      }
    case .authorized:
      chooseCalendar()
    case .denied:
      let alert = UIAlertController(
        title: "\(NSLocalizedString("no-perm", comment: ""))",
        message: "\(NSLocalizedString("no-perm-msg", comment: ""))",
        preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    default: return
    }
  }

  @objc 
  private func onModalDismiss(_ notification: Notification) {
    if let result = notification.userInfo {
      SDefaults.studentId = ((result as! [String : Any])["UserId"] as! Int)
      SDefaults.studentName = ((result as! [String : Any])["UserName"] as! String)
      scheduleSource.userId = SDefaults.studentId
      groupButton.configuration?.title = SDefaults.studentName
      placeholder.isHidden = true
      updateSchedule()
    }
  }

  private func updateSchedule(newWeekOffset: Int? = nil) {
    for day in self.scheduleSource.schedule {
      day.classes.removeAll()
    }
    schedule.prepareForUpdate()

    if let weekOffset = newWeekOffset {
      self.scheduleSource.weekOffset = weekOffset
    } else {
      scheduleSource.updateData()
    }
  }

  private func chooseCalendar() {
    let ccvc = EKCalendarChooser(
      selectionStyle: .single,
      displayStyle: .writableCalendarsOnly,
      eventStore: SExportManager.shared.eventStore)
    ccvc.delegate = self
    ccvc.showsDoneButton = true
    ccvc.showsCancelButton = true

    calendarSelectionViewController.pushViewController(ccvc, animated: false)
    present(calendarSelectionViewController, animated: true, completion: nil)
  }

  private func openClassDetails() {
    guard let lastSelectedClass, let classData = scheduleSource.classData(number: lastSelectedClass.number, on: lastSelectedClass.day) else { return }
    let viewController = ClassDetailsViewController(classData: classData)
    let navigationController = UINavigationController(rootViewController: viewController)
    present(navigationController, animated: true)
  }
}

extension StudentScheduleViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView.tag == 0 || tableView.tag == 7 {
      return 0
    } else {
      let numberOfClasses = scheduleSource.numberOfClasses(on: SWeekDay(rawValue: tableView.tag)!)
      return numberOfClasses
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: schedule.reuseIdentifier, for: indexPath) as! SScheduleTableViewCell
    let classData = scheduleSource.classData(number: indexPath.row, on: SWeekDay(rawValue: tableView.tag)!)!
    cell.configure(with: classData)
    return cell
  }
}

extension StudentScheduleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    lastSelectedClass = SelectedClass(
      day: SWeekDay(rawValue: tableView.tag)!,
      number: indexPath.row)
    openClassDetails()
  }
}

extension StudentScheduleViewController: EKCalendarChooserDelegate {
  func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
    if let selectedCalendar = calendarChooser.selectedCalendars.first {
      do {
        let schedule = scheduleSource.schedule
        let weekOffset = scheduleSource.weekOffset
        try SExportManager.shared.export(schedule, weekOffset: weekOffset, into: selectedCalendar)
      } catch let error {
        print(error.localizedDescription)
      }
    }
    calendarSelectionViewController.dismiss(animated: true)
  }

  func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
    calendarSelectionViewController.dismiss(animated: true)
  }
}
