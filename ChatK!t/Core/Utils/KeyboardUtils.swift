//
//  KeyboardUtils.swift
//  AFNetworking
//
//  Created by ben3 on 11/04/2021.
//

import Foundation
import UIKit

public class KeyboardInfo {
    
    public let frame: CGRect
    public let duration: Double
    public let curve: UIView.AnimationOptions
    
    init(frame: CGRect, duration: Double, curve: UIView.AnimationOptions) {
        self.frame = frame
        self.duration = duration
        self.curve = curve
    }
    
    public static func from(_ info: [AnyHashable: Any]?) -> KeyboardInfo? {
        if let info = info,
           let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
           let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            return KeyboardInfo(frame: frame.cgRectValue, duration: duration.doubleValue, curve: UIView.AnimationOptions(rawValue: curve.uintValue))
        }
        return nil
    }
    
    public func height(view: UIView? = nil) -> CGFloat {
        var keyboardHeight = UIScreen.main.bounds.height - frame.origin.y
        if #available(iOS 11, *) {
            if keyboardHeight > 0, let view = view {
                keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
            }
        }
        return keyboardHeight
    }
}

public class KeyboardListener {
    
    public var willShow: ((KeyboardInfo) -> Void)?
    public var didShow: ((KeyboardInfo) -> Void)?
    public var willHide: ((KeyboardInfo) -> Void)?
    public var didHide: ((KeyboardInfo) -> Void)?
    public var willChangeFrame: ((KeyboardInfo) -> Void)?

    init() {
        
    }
    
    public func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    public func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc public func keyboardWillChangeFrame(_ notification: Notification) {
        if let callback = willChangeFrame, let data = KeyboardInfo.from(notification.userInfo) {
            callback(data)
        }
    }
    
    @objc public func keyboardWillShow(_ notification: Notification) {
        if let info = KeyboardInfo.from(notification.userInfo) {
            willShow?(info)
        }
    }

    @objc public func keyboardDidShow(_ notification: Notification) {
        if let info = KeyboardInfo.from(notification.userInfo) {
            didShow?(info)
        }
    }

    @objc public func keyboardWillHide(_ notification: Notification) {
        if let info = KeyboardInfo.from(notification.userInfo) {
            willHide?(info)
        }
    }

    @objc public func keyboardDidHide(_ notification: Notification) {
        if let info = KeyboardInfo.from(notification.userInfo) {
            didHide?(info)
        }
    }

}
