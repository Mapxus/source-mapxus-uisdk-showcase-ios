//
//  SampleNavigationController.swift
//  UISDKKmpSample
//

import UIKit

final class SampleNavigationController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBarAppearance()
  }

  private func configureNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .systemBackground
    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.compactAppearance = appearance
    navigationBar.isTranslucent = false
    navigationBar.tintColor = .label
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController?.supportedInterfaceOrientations ?? .portrait
  }

  override var shouldAutorotate: Bool {
    return topViewController?.shouldAutorotate ?? false
  }
}

