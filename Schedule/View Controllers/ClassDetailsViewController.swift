//
//  ClassDetailsViewController.swift
//  Schedule
//
//  Created by Egor Molchanov on 27.05.2020.
//  Copyright © 2020 Egor and the fucked up. All rights reserved.
//

import UIKit
import MapKit

final class ClassDetailsViewController: UIViewController {
  private let classData: SClass
  private let textBuilder = ClassDetailsTextBuilder()

  private lazy var scrollView: UIScrollView = {
    let view = UIScrollView(frame: UIScreen.main.bounds)
    view.backgroundColor = .systemBackground
    return view
  }()
  private lazy var textView: UITextView = {
    let view = UITextView()
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    view.isEditable = false
    view.delegate = self
    return view
  }()
  private lazy var mapView: MKMapView = {
    let view = MKMapView()
    view.isPitchEnabled = false
    view.isZoomEnabled = false
    view.isRotateEnabled = false
    view.isScrollEnabled = false
    view.layer.cornerRadius = 6.0
    return view
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init(classData: SClass) {
    self.classData = classData
    super.init(nibName: nil, bundle: nil)
    let text = textBuilder.buildDetailsText(fromClassData: self.classData)
    textView.attributedText = text
  }

  override func loadView() {
    view = scrollView
    scrollView.addSubview(textView)
    scrollView.addSubview(mapView)

    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(handleCloseItemTap))
    navigationItem.rightBarButtonItem?.tintColor = .secondarySystemFill
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    SBuildingsManager.shared.setCoordinates(for: Int(classData.building)!) { [weak self] latitude, longtitude in
      guard let self, let lat = latitude, let long = longtitude else { return }
      let annotation = MKPointAnnotation()
      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
      annotation.coordinate = coordinate
      self.mapView.addAnnotation(annotation)
      self.mapView.setCenter(coordinate, animated: false)
      self.mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(floatLiteral: 300.0), longitudinalMeters: CLLocationDistance(floatLiteral: 300.0)), animated: false)
    }
  }

  override func viewDidLayoutSubviews() {
    let textViewSize = textView.sizeThatFits(CGSize(width: scrollView.bounds.width - 32.0, height: .infinity))
    textView.frame = CGRect(origin: CGPoint(x: 16.0, y: 36.0), size: textViewSize)
    mapView.frame = CGRect(origin: CGPoint(x: 16.0, y: textView.frame.maxY + 16.0), size: CGSize(width: scrollView.bounds.width - 32.0, height: 150.0))
    scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: textViewSize.height + mapView.frame.size.height + 36.0 * 3.0)
  }

  @objc
  private func handleCloseItemTap() {
    dismiss(animated: true)
  }
}

extension ClassDetailsViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    guard URL.absoluteString == "teacher-details", let employeeID = classData.employeeId else { return false }
    let viewController = EmployeeDetailsViewController(employeeID: employeeID)
    let navigationController = UINavigationController(rootViewController: viewController)
    present(navigationController, animated: true)
    return false
  }
}
