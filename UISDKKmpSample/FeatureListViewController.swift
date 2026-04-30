//
//  FeatureListViewController.swift
//  UISDKKmpSample
//
//  点击某个分类后进入，展示该分类下的功能列表
//

import UIKit
import SnapKit

final class FeatureListViewController: UIViewController {

    /// 当前选中的分类标题（用于从 featureList 取功能项）
    private let categoryTitle: String

    /// 功能列表（来自 FeatureConstants.featureList）
    private lazy var features: [String] = {
        FeatureConstants.featureList[categoryTitle] ?? []
    }()

    init(categoryTitle: String) {
        self.categoryTitle = categoryTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.tableFooterView = UIView()
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = categoryTitle
        navigationItem.backButtonTitle = "Back"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension FeatureListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        features.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = features[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let featureName = features[indexPath.row]
        guard let nav = navigationController,
              let vc = FeatureConstants.viewController(forFeature: featureName) else { return }
        nav.pushViewController(vc, animated: true)
    }
}
