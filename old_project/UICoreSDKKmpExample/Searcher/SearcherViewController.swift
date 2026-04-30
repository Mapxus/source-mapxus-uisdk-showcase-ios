//
//  SearcherViewController.swift
//  UICoreSDKKmpExample
//
//  Created by guochenghao on 2025/12/31.
//

import UIKit
import DropInUISDK

class SearcherViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logTextView = UITextView()
    private let sdk = DISdk(diConfig: DIConfigBuilder().build())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 创建按钮数组
        let buttonTitles = [
            "同步获取 venue by name",
            "异步获取 venue by name",
            "同步获取 venue by ids",
            "异步获取 venue by ids",
            "同步获取周边venue",
            "异步获取周边venue",
            "同步获取 poi by id",
            "异步获取 poi by id",
            "同步获取 poi by bound",
            "异步获取 poi by bound",
        ]
        
        let buttonsPerRow: Int = 2
        let buttonWidth: CGFloat = (view.frame.width - 48) / CGFloat(buttonsPerRow)
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 8
        
        for (index, title) in buttonTitles.enumerated() {
            let button = createButton(with: title, tag: index)
            contentView.addSubview(button)
            
            let row = index / buttonsPerRow
            let column = index % buttonsPerRow
            
            let xPosition = CGFloat(column) * (buttonWidth + spacing) + 16
            let yPosition = CGFloat(row) * (buttonHeight + spacing) + 16
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xPosition),
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight),
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: yPosition)
            ])
        }
        
        let totalRows = (buttonTitles.count + buttonsPerRow - 1) / buttonsPerRow
        let totalHeight = CGFloat(totalRows) * (buttonHeight + spacing) + 32
        
        contentView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        
        // 配置日志文本显示窗
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        logTextView.isEditable = false
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.textColor = .darkGray
        view.addSubview(logTextView)
        
        NSLayoutConstraint.activate([
            logTextView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func createButton(with title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let titles = [
            "同步获取 venue by name",
            "异步获取 venue by name",
            "同步获取 venue by ids",
            "异步获取 venue by ids",
            "同步获取周边venue",
            "异步获取周边venue",
            "同步获取 poi by id",
            "异步获取 poi by id",
            "同步获取 poi by bound",
            "异步获取 poi by bound",
        ]
        
        let message = "[\(getCurrentTime())] 点击了: \(titles[sender.tag])\n"
        addLog(message)
        
        // 在这里添加对应的API调用逻辑
        switch sender.tag {
        case 0:
            logMessage("正在同步获取 venue by name...")
            syncSearchVenueByName()
            
        case 1:
            logMessage("正在异步获取 venue by name...")
            asyncSearchVenueByName()
        case 2:
            logMessage("正在同步获取 venue by ids...")
            syncSearchVenueByIds()
        case 3:
            logMessage("正在异步获取 venue by ids...")
            asyncSearchVenueByIds()
        case 4:
            logMessage("正在同步获取周边venue...")
            syncSearchNearbyVenues()
        case 5:
            logMessage("正在异步获取周边venue...")
            asyncSearchNearbyVenues()
        case 6:
            logMessage("正在同步获取 poi by id...")
            syncSearchPoiById()
        case 7:
            logMessage("正在异步获取 poi by id...")
            asyncSearchPoiById()
        case 8:
            logMessage("正在同步获取 poi by bound...")
            syncSearchPoiByBound()
        case 9:
            logMessage("正在异步获取 poi by bound...")
            asyncSearchPoiByBound()
        default:
            break
        }
    }
    
    private func addLog(_ message: String) {
        logTextView.text.append(message)
        let range = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(range)
    }
    
    private func logMessage(_ message: String) {
        let fullMessage = "[\(getCurrentTime())] \(message)\n"
        addLog(fullMessage)
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    // MARK: - Venue by name 搜索
        
    private func syncSearchVenueByName() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            do {
                let venueList = try await dataSearcher.searchVenuesByName(queryName: "K11")
                if !venueList.isEmpty {
                    logMessage("同步 venue by name 成功: \(venueList)")
                } else {
                    logMessage("venue by name 数据为空")
                }
            } catch {
                logMessage("同步 venue by name 失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func asyncSearchVenueByName() {
        let dataSearcher = self.sdk.getDataSearcher()
        dataSearcher.searchVenuesByName(queryName: "K11") { [weak self] venueList in
            guard let self = self else { return }
            if !venueList.isEmpty {
                self.logMessage("异步 venue by name 成功: \(venueList)")
            } else {
                self.logMessage("venue by name 异步数据为空")
            }
        }
    }
    
    // MARK: - Venue by ids 搜索
    private let leeTungAvenue = "00752cce7b3d43eb96a72a566fe2f4f3"
    private let mPlusMuseum = "06d7e41af5154838a8d6ddda7d10cb0a"
    private let apm = "8423acf2a7594a989f272f479f866cfa"
    private let k11ArtMall = "caab5a38-79e1-11e8-8453-951df499024d"
    private let harbourCity = "d76ee96d15294c79bdd5c479c20a0151"
    private let taiKwun = "e679b6fc0818456aa1867aa021a3e84a"
    private let centralMarket = "ff9cf333fbea41dc9545c62261312d5c"
    private let chinaHongKongCity = "08da4a01cf0545cb9e603f7602976942"
    private let centralStarFerryPier = "5006547171e84784a187078d10f336f2"
    private let hongKongUniversity = "55ca79c95a9a480dbbf2c0f6d9fd1998"
    private let citywalk = "4f610b55f04f4d77b75b829c64a69a71"
    
    private func syncSearchVenueByIds() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            do {
                let venueIds = [
                    leeTungAvenue,
                    mPlusMuseum,
                    apm,
                    k11ArtMall,
                    harbourCity,
                    taiKwun,
                    centralMarket,
                    chinaHongKongCity,
                    centralStarFerryPier,
                    hongKongUniversity,
                    citywalk
                ]
                let venueList = try await dataSearcher.searchVenuesByIds(venueIds: venueIds)
                if !venueList.isEmpty {
                    logMessage("同步 venue by ids 成功: \(venueList)")
                } else {
                    logMessage("venue by ids 数据为空")
                }
            } catch {
                logMessage("同步 venue by ids 失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func asyncSearchVenueByIds() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            let venueIds = [
                leeTungAvenue,
                mPlusMuseum,
                apm,
                k11ArtMall,
                harbourCity,
                taiKwun,
                centralMarket,
                chinaHongKongCity,
                centralStarFerryPier,
                hongKongUniversity,
                citywalk
            ]
            dataSearcher.searchVenuesByIds(venueIds: venueIds) { [weak self] venueList in
                guard let self = self else { return }
                if !venueList.isEmpty {
                    self.logMessage("异步 venue by ids 成功: \(venueList)")
                } else {
                    self.logMessage("venue by ids 异步数据为空")
                }
            }
        }
    }
    
    // MARK: - 周边Venue搜索
    private func syncSearchNearbyVenues() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            do {
                // 搜索周边的venues（以K11为中心，搜索范围内的venue）
                let venues = try await dataSearcher.searchVenuesNearby(latitude: 22.29445, longitude: 114.174815, radius: 1000)
                if !venues.isEmpty {
                    logMessage("同步周边venue 成功: 找到 \(venues.count) 个venue")
                    logMessage("详细数据: \(venues)")
                } else {
                    logMessage("周边venue 数据为空")
                }
            } catch {
                logMessage("同步周边venue 失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func asyncSearchNearbyVenues() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            dataSearcher.searchVenuesNearby(latitude: 22.29445, longitude: 114.174815, radius: 1000) { [weak self] venues in
                guard let self = self else { return }
                if !venues.isEmpty {
                    self.logMessage("异步周边venue 成功: 找到 \(venues.count) 个venue")
                    self.logMessage("详细数据: \(venues)")
                } else {
                    self.logMessage("周边venue 异步数据为空")
                }
            }
        }
    }
    
    // MARK: - POI by id 搜索
    private func syncSearchPoiById() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            do {
                if let poiData = try await dataSearcher.searchPoiById(poiId: "12735072") {
                    logMessage("同步 poi by id 成功: \(poiData)")
                } else {
                    logMessage("poi by id 数据为空")
                }
            } catch {
                logMessage("同步 poi by id 失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func asyncSearchPoiById() {
        let dataSearcher = self.sdk.getDataSearcher()
        dataSearcher.searchPoiById(poiId: "12735072") { [weak self] poiData in
            guard let self = self else { return }
            if let poi = poiData {
                self.logMessage("异步 poi by id 成功: \(poi)")
            } else {
                self.logMessage("poi by id 异步数据为空")
            }
        }
    }
    
    // MARK: - POI by bound 搜索
    private func syncSearchPoiByBound() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            do {
                let bounds = Bounds(maxLat: 22.2900, maxLon: 114.1650, minLat: 22.3050, minLon: 114.1850)
                let poi = try await dataSearcher.searchPoiByBounds(bounds: bounds, queryName: "c")
                if let thePoi = poi {
                    logMessage("同步 poi by bound 成功: \(thePoi)")
                } else {
                    logMessage("poi by bound 数据为空")
                }
            } catch {
                logMessage("同步 poi by bound 失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func asyncSearchPoiByBound() {
        Task { [weak self] in
            guard let self = self else { return }
            let dataSearcher = self.sdk.getDataSearcher()
            // 搜索指定区域内的POI
            let bounds = Bounds(maxLat: 22.2900, maxLon: 114.1650, minLat: 22.3050, minLon: 114.1850)
            dataSearcher.searchPoiByBounds(bounds: bounds, queryName: "c") { [weak self] poi in
                guard let self = self else { return }
                if let thePoi = poi {
                    self.logMessage("异步 poi by bound 成功: \(thePoi)")
                } else {
                    self.logMessage("poi by bound 异步数据为空")
                }
            }
        }
    }
}

