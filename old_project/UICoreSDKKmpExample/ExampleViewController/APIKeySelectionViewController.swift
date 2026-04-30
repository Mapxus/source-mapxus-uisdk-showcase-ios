//
//  APIKeySelectionViewController.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2026/1/8.
//

import UIKit
import MapxusBaseSDK

struct APIKeyItem {
    let apiKey: String
    let secret: String
}

class APIKeySelectionViewController: UIViewController {
    
    private let apiKeyItems: [APIKeyItem] = [
        APIKeyItem(apiKey: "b3000223771f4eb2becd5a95aaa13d64", secret: "ae4173c7702148c98f3fb64b2ae079a1"),
        APIKeyItem(apiKey: "c6dd4626575e40f485ecff38eff7bdb3", secret: "40ddcf56bab24c2e8a08a84c4e97ffa4"),
        APIKeyItem(apiKey: "52500383377b4b3a91282449f7e4a927", secret: "4b169b01634f4009a7cdae2f66ae041"),
        APIKeyItem(apiKey: "a1f6f6cef23b4895b42faf83e289427c", secret: "59ea5eab41b142f3a73ef2cf2ea65802"),
    ]
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(APIKeyCell.self, forCellReuseIdentifier: APIKeyCell.identifier)
        tv.backgroundColor = .white
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Select API Key", comment: "")
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupSubviews()
    }
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}

extension APIKeySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiKeyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: APIKeyCell.identifier, for: indexPath) as! APIKeyCell
        let item = apiKeyItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = apiKeyItems[indexPath.row]
        registerWithAPIKey(selectedItem)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension APIKeySelectionViewController: MXMServiceDelegate {
    func registerMXMServiceSuccess() {
        // 显示成功提示
        let alertController = UIAlertController(
            title: NSLocalizedString("Success", comment: ""),
            message: NSLocalizedString("API Key registered successfully", comment: ""),
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func registerMXMServiceFailWithError(_ error: any Error) {
        // 显示失败提示
        let alertController = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("API Key registered fail: \(error.localizedDescription)", comment: ""),
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    
    private func registerWithAPIKey(_ item: APIKeyItem) {
        // 注册 API key
        MXMMapServices.shared().delegate = self
        MXMMapServices.shared().register(withApiKey: item.apiKey, secret: item.secret)
    }
}

// MARK: - APIKeyCell

class APIKeyCell: UITableViewCell {
    static let identifier = "APIKeyCell"
    
    private let apiKeyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(apiKeyLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            apiKeyLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            apiKeyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            apiKeyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            apiKeyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: APIKeyItem) {
        apiKeyLabel.text = "API Key: \(item.apiKey)"
    }
}
