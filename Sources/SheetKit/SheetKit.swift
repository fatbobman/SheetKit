//
//  SheetKit.swift
//  SheetManager
//
//  Created by Yang Xu on 2021/9/16.
//

import Foundation
import SwiftUI
import UIKit

public struct SheetKit {
    /// dismiss all sheets
    /// - Parameters:
    ///   - flag: Pass true to animate the transition.
    ///   - completion: The block to execute after the view controller is dismissed. This block has no return value and takes no parameters. You may specify nil for this parameter.
    public func dismissAllSheets(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        rootViewController?.dismiss(animated: flag, completion: completion)
    }

    /// dismiss top sheet
    /// - Parameters:
    ///   - flag: Pass true to animate the transition.
    ///   - completion: The block to execute after the view controller is dismissed. This block has no return value and takes no parameters. You may specify nil for this parameter.
    public func dismiss(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        rootViewController?.topmostPresentingViewController?.dismiss(animated: flag, completion: completion)
    }

    public func present<Content: View>(in controller: ControllerSource = .rootController,
                                       with style: SheetStyle = .sheet,
                                       animated:Bool = true,
                                       completion: (() -> Void)? = nil,
                                       configuration: BottomSheetConfiguration? = nil,
                                       detentIdentifier: Binding<UISheetPresentationController.Detent.Identifier>? = nil,
                                       content: () -> Content) {
        let viewController = controller == .rootController ? rootViewController?.topmostPresentedViewController : rootViewController?.topmostViewController

        let contentViewController:UIViewController

        switch style {
            case .sheet:
                contentViewController = UIHostingController(rootView: content())
            case .fullScreenCover:
                contentViewController = UIHostingController(rootView: content())
                contentViewController.modalPresentationStyle = .fullScreen
            case .bottomSheet:
                let configuration = BottomSheetConfiguration.default
                contentViewController = BottomSheetViewController(detents: configuration.detents,
                                                                  largestUndimmedDetentIdentifier: configuration.largestUndimmedDetentIdentifier,
                                                                  prefersGrabberVisible: configuration.prefersGrabberVisible,
                                                                  prefersScrollingExpandsWhenScrolledToEdge: configuration.prefersScrollingExpandsWhenScrolledToEdge,
                                                                  prefersEdgeAttachedInCompactHeight: configuration.prefersEdgeAttachedInCompactHeight,
                                                                  widthFollowsPreferredContentSizeWhenEdgeAttached: configuration.widthFollowsPreferredContentSizeWhenEdgeAttached,
                                                                  detentIdentifier: detentIdentifier,
                                                                  content: content())
            case .customBottomSheet:
                guard let configuration = configuration else {fatalError("configuration can't be nil in customBottomSheet style.")}
                contentViewController = BottomSheetViewController(detents: configuration.detents,
                                                                  largestUndimmedDetentIdentifier: configuration.largestUndimmedDetentIdentifier,
                                                                  prefersGrabberVisible: configuration.prefersGrabberVisible,
                                                                  prefersScrollingExpandsWhenScrolledToEdge: configuration.prefersScrollingExpandsWhenScrolledToEdge,
                                                                  prefersEdgeAttachedInCompactHeight: configuration.prefersEdgeAttachedInCompactHeight,
                                                                  widthFollowsPreferredContentSizeWhenEdgeAttached: configuration.widthFollowsPreferredContentSizeWhenEdgeAttached,
                                                                  detentIdentifier: detentIdentifier,
                                                                  content: content())

        }

        viewController?.present(contentViewController, animated: animated, completion: completion)
    }

    public init(){}

}

public extension SheetKit {
    var keyWindow: UIWindow? { UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .map { $0 as? UIWindowScene }
        .compactMap { $0 }
        .first?.windows
        .filter { $0.isKeyWindow }.first
    }

    var rootViewController: UIViewController? {
        keyWindow?.rootViewController
    }
}

public extension SheetKit {
    /// Sheet 类型
    enum SheetStyle {
        case sheet
        case fullScreenCover
        case bottomSheet
        case customBottomSheet
    }

    /// 在哪个ViewController上添加sheet
    enum ControllerSource {
        case rootController
        case topController
    }

    struct BottomSheetConfiguration {
        init(detents: [UISheetPresentationController.Detent],
             largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?,
             prefersGrabberVisible: Bool,
             prefersScrollingExpandsWhenScrolledToEdge: Bool,
             prefersEdgeAttachedInCompactHeight: Bool,
             widthFollowsPreferredContentSizeWhenEdgeAttached: Bool,
             preferredCornerRadius: CGFloat?)
        {
            self.detents = detents
            self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
            self.prefersGrabberVisible = prefersGrabberVisible
            self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
            self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
            self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
            self.preferredCornerRadius = preferredCornerRadius
        }

        let detents: [UISheetPresentationController.Detent]
        let largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
        let prefersGrabberVisible: Bool
        let prefersScrollingExpandsWhenScrolledToEdge: Bool
        let prefersEdgeAttachedInCompactHeight: Bool
        let widthFollowsPreferredContentSizeWhenEdgeAttached: Bool
        let preferredCornerRadius: CGFloat?

        static let `default` = BottomSheetConfiguration(detents: [.medium(), .large()],
                                                        largestUndimmedDetentIdentifier: nil,
                                                        prefersGrabberVisible: false,
                                                        prefersScrollingExpandsWhenScrolledToEdge: true,
                                                        prefersEdgeAttachedInCompactHeight: true,
                                                        widthFollowsPreferredContentSizeWhenEdgeAttached: true,
                                                        preferredCornerRadius: nil)
    }
}

// MARK: - Environment

public struct SheetKitKey:EnvironmentKey{
    public static var defaultValue = SheetKit()
}

public extension EnvironmentValues{
    var sheetKit:SheetKit{
        get{self[SheetKitKey.self]}
    }
}

