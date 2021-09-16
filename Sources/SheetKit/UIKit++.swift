//
//  UIKit++.swift
//  
//
//  Created by Yang Xu on 2021/9/16.
//

import UIKit

extension UIViewController {
    var topmostPresentedViewController: UIViewController? {
        presentedViewController?.topmostPresentedViewController ?? self
    }

    var topmostViewController: UIViewController? {
        if let controller = (self as? UINavigationController)?.visibleViewController {
            return controller.topmostViewController
        } else if let controller = (self as? UITabBarController)?.selectedViewController {
            return controller.topmostViewController
        } else if let controller = presentedViewController {
            return controller.topmostViewController
        } else {
            return self
        }
    }

    var topmostPresentingViewController: UIViewController? {
        topmostViewController?.presentingViewController
    }
}
