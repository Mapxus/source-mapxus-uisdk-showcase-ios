//
//  UIViewController+Extension.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

extension UIViewController {
    
    static func topViewController(_ base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return topViewController(nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return topViewController(tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return topViewController(presented)
            }
            return base
        }
 
    
    /// 显示带跳转设置的提示框（可自定义跳转URL）
    func showAlert(title: String?,
                                message: String?,
                                confirmTitle: String = "Cancel",
                                settingsURL: URL = URL(string: UIApplication.openSettingsURLString)!, cancelHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            
        }
        
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
    }
}
