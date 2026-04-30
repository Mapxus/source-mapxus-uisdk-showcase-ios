//
//  NSMutableAttributedStringExtension.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import Foundation
import UIKit


extension NSMutableAttributedString {
    
    func addFont(_ font: UIFont, on range: NSRange) {
        if self.length < range.location + range.length { return }
        let attrs = [NSAttributedString.Key.font: font]
        self.addAttributes(attrs, range: range)
    }

    /// 设置字体颜色
    func addForegroundColor(_ color: UIColor, range: NSRange) {
        if self.length < range.location + range.length {
            return
        }
        
        let attrs = [NSAttributedString.Key.foregroundColor: color]
        self.addAttributes(attrs, range: range)
    }
    
}
