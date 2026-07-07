//
//  CategoryListViewController.swift
//  UISDKKmpSample
//
//  Left category list presented with overCurrentContext; the left table slides in with a dimming overlay
//

import UIKit
import SnapKit

protocol CategoryListViewControllerDelegate: AnyObject {
    func categoryListViewController(_ menu: CategoryListViewController, didSelect index: Int)
    func categoryListViewControllerDidDismiss(_ menu: CategoryListViewController)
}

final class CategoryListViewController: UIViewController {

    static func present(
        on presentingViewController: UIViewController,
        delegate: CategoryListViewControllerDelegate,
        titles: [String],
        defaultSelect index: Int
    ) {
        let vc = CategoryListViewController()
        vc.delegate = delegate
        vc.titles = titles
        vc.defaultSelected = index
        // overFullScreen: the overlay covers the full screen, including the status bar, notch, and areas outside the safe area
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        presentingViewController.present(vc, animated: false) {
            vc.showMenu()
        }
    }

    private weak var delegate: CategoryListViewControllerDelegate?
    private var titles: [String] = []
    private var defaultSelected: Int = 0

    private let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.alpha = 0
        return v
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.bounces = false
        tv.separatorStyle = .none
        tv.tableFooterView = UIView()
        return tv
    }()

    private let headerView = CategoryListHeaderView()
    private var tableWidth: CGFloat = 0
    private var tableLeading: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        tableWidth = min(283, UIScreen.main.bounds.width / 3 * 2)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        view.addSubview(bgView)
        view.addSubview(tableView)

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(tableWidth)
            tableLeading = make.leading.equalToSuperview().offset(-tableWidth).constraint
        }

        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: tableWidth, height: 216)
        headerView.applyLayout(tableWidth: tableWidth)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        bgView.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if defaultSelected >= 0, defaultSelected < titles.count {
            let idx = IndexPath(row: defaultSelected, section: 0)
            tableView.selectRow(at: idx, animated: false, scrollPosition: .none)
        }
    }

    private func showMenu() {
        tableLeading?.update(offset: -tableWidth)
        bgView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.tableLeading?.update(offset: 0)
            self.view.layoutIfNeeded()
            self.bgView.alpha = 0.5
        }
    }

    @objc private func dismissMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableLeading?.update(offset: -self.tableWidth)
            self.view.layoutIfNeeded()
            self.bgView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false) {
                self.delegate?.categoryListViewControllerDidDismiss(self)
            }
        })
    }
}

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = titles[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.categoryListViewController(self, didSelect: indexPath.row)
        dismissMenu()
    }
}

// MARK: - Header

private final class CategoryListHeaderView: UIView {

    private let boxView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 119/255, green: 120/255, blue: 124/255, alpha: 1)
        return v
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Mapxus UISDK"
        l.font = .boldSystemFont(ofSize: 25)
        l.textColor = .white
        return l
    }()

    private let subNameLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont(name: "PingFang SC", size: 16) ?? .systemFont(ofSize: 16)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        l.text = "iOS Sample App (V\(version))"
        return l
    }()

    private var didSetup = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        clipsToBounds = false
        addSubview(boxView)
        boxView.addSubview(nameLabel)
        boxView.addSubview(subNameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyLayout(tableWidth: CGFloat) {
        guard !didSetup else { return }
        didSetup = true

        boxView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-39)
            make.width.equalTo(tableWidth)
            make.height.equalTo(36)
        }

        subNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(tableWidth)
            make.height.equalTo(30)
        }
    }
}
