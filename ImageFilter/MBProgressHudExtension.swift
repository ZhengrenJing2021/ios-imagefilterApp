//
//  MBProgressHudExtension.swift
//  ImageFilter
//
//  Library that manages events such as error warning, log-in success notification,etc.
//

import Foundation
import UIKit
import MBProgressHUD
let HUD_Duration_Infinite = -1
let HUD_Duration_Normal = 1.5
let HUD_Duration_Short = 0.5
extension MBProgressHUD {
    @discardableResult
    class func showAdded(view: UIView, duration showTime: Double, animated: Bool) -> (MBProgressHUD) {
        var animated = animated
        let existHUD:MBProgressHUD = MBProgressHUD(view: view)
        if existHUD != nil{
            MBProgressHUD.hide(for: view, animated: false)
            animated = false
        }
        
        let showView = self.showAdded(to: view, animated: animated)

        if Int(showTime) != HUD_Duration_Infinite {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(showTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                MBProgressHUD.hide(for: view, animated: false)
            })
        }
        return showView
    }

    @discardableResult
    class func showAdded(view: UIView, duration showTime: TimeInterval, withText text: String?, animated: Bool) -> (MBProgressHUD) {
        let showView = self.showAdded(view: view, duration: showTime, animated: animated)
        showView.isUserInteractionEnabled = false
        showView.mode = .text
        showView.label.text = text
        return showView
    }

    @discardableResult
    class func showAdded(view: UIView, icon image: UIImage?, duration showTime: TimeInterval, withText text: String?, animated: Bool) -> (MBProgressHUD) {
        let showView = self.showAdded(view: view, duration: showTime, animated: animated)
        showView.isUserInteractionEnabled = false
        showView.mode = .customView
        return showView
    }
}
