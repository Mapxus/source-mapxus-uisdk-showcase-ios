//
//  MapxusMapViewController.swift
//  UISDKKmpSample
//

import UIKit

/// Wraps `MapxusMapView` in a `UIViewController` so it can be pushed/presented.
final class MapxusMapViewController: UIViewController {
    private static let defaultVenueId = "3cd9b17d-f3f4-4afd-ba34-5e3fad2518a6"

    private let target: MapxusMapView.Target
    private let language: String

    private var mapView: MapxusMapView?

    init(
        target: MapxusMapView.Target? = nil,
        language: String = "system"
    ) {
        self.target = target ?? .venue(mapId: MapxusMapViewController.defaultVenueId)
        self.language = language
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mapxus"
        view.backgroundColor = .systemBackground

        let mv = MapxusMapView(target: target, language: language)
        mv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mv)
        NSLayoutConstraint.activate([
            mv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        mapView = mv
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            mapView?.cleanup()
        }
    }
}

