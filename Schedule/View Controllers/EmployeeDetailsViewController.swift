//
//  EmployeeDetailsViewController.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit

final class EmployeeDetailsViewController: UIViewController {
  private let employeeID: Int
  private let textScraper = EmployeeDataScraper()
  private let textBuilder = EmployeeDetailsTextBuilder()

  private lazy var scrollView: UIScrollView = {
    let view = UIScrollView()
    view.backgroundColor = .systemBackground
    return view
  }()
  private lazy var imageView: UIImageView = {
    let view = UIImageView(image: UIImage.defaultProfilePicture)
    view.contentMode = .scaleAspectFill
    return view
  }()
  private lazy var textView: UITextView = {
    let view = UITextView()
    view.isScrollEnabled = false
    view.isEditable = false
    return view
  }()
  private lazy var activityIndicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.hidesWhenStopped = true
    return view
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init(employeeID: Int) {
    self.employeeID = employeeID
    super.init(nibName: nil, bundle: nil)
  }

  override func loadView() {
    view = scrollView
    scrollView.addSubview(activityIndicatorView)
    scrollView.addSubview(imageView)
    scrollView.addSubview(textView)
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(handleCloseItemTap))
    navigationItem.rightBarButtonItem?.tintColor = .secondarySystemFill
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Task {
      do {
        prepareForUpdating()
        try await updateData()
        cleanupAfterUpdating()
      } catch {
        print(error.localizedDescription)
        cleanupAfterUpdating()
      }
    }
  }

  @MainActor
  private func prepareForUpdating() {
    activityIndicatorView.startAnimating()
    imageView.isHidden = true
    textView.isHidden = true
    view.setNeedsLayout()
  }

  private func updateData() async throws {
    // TODO: Add placeholder for empty data or loading failure
    let html = try await NetworkWorker().data(from: Oreluniver.employee(identifier: employeeID))
    guard let employee = try textScraper.scrapeData(fromHTML: html, forEmployeeID: employeeID) else { return }
    let attributedText = textBuilder.buildDetailsText(fromEmployeeDetails: employee)
    await MainActor.run {
      self.textView.attributedText = attributedText
    }

    guard let imageURL = employee.image else { return }
    let employeeImageData = try await NetworkWorker().data(from: Oreluniver.other(path: imageURL))
    guard let image = UIImage(data: employeeImageData) else { return }
    await MainActor.run {
      imageView.image = image
    }
  }

  @MainActor
  private func cleanupAfterUpdating() {
    activityIndicatorView.stopAnimating()
    imageView.isHidden = false
    textView.isHidden = false
    view.setNeedsLayout()
  }

  override func viewDidLayoutSubviews() {
    if imageView.isHidden && textView.isHidden {
      scrollView.contentSize = view.bounds.size
      activityIndicatorView.center = view.center
    } else {
      imageView.frame = CGRect(origin: CGPoint(x: (view.bounds.size.width - 180.0) / 2.0, y: 36.0), size: CGSize(width: 180.0, height: 180.0))
      imageView.layer.cornerRadius = 90.0
      imageView.clipsToBounds = true

      let textViewSize = textView.sizeThatFits(CGSize(width: view.bounds.size.width - 16.0 * 2.0, height: .infinity))
      textView.frame = CGRect(origin: CGPoint(x: 16.0, y: imageView.frame.maxY + 36.0), size: textViewSize)

      scrollView.contentSize = CGSize(width: view.bounds.width, height: textView.frame.maxY)
    }
  }

  @objc
  private func handleCloseItemTap() {
    dismiss(animated: true)
  }
}
