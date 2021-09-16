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

    /// present seht
    /// - Parameters:
    ///   - controller: 从哪个UIViewController创建sheet。默认值即可
    ///   - style: Sheet 的样式，目前支持 sheet fullScreenCover bottomSheet 以及 customBottomSheet（自定义）
    ///   - animated: 是否开启动画
    ///   - afterPresent: 展示后执行的block
    ///   - onDisappear: viewDidDisappeare时执行的block
    ///   - configration: 自定义bottomSheet的配置
    ///   - detentIdentifier: 当modal状态发生变化时（高度变化）通知绑定值
    ///   - content: 视图内容
    public func present<Content: View>(in controller: ControllerSource = .rootController,
                                       with style: SheetStyle = .sheet,
                                       animated: Bool = true,
                                       afterPresent: (() -> Void)? = nil,
                                       onDisappear:(() -> Void)? = nil,
                                       configuration: BottomSheetConfiguration? = nil,
                                       detentIdentifier: Binding<UISheetPresentationController.Detent.Identifier>? = nil,
                                       content: () -> Content)
    {
        let viewController = controller == .rootController ? rootViewController?.topmostPresentedViewController : rootViewController?.topmostViewController

        let contentViewController: UIViewController

        switch style {
        case .sheet:
            contentViewController = MyUIHostingController(rootView: content(),onDisappear: onDisappear)
        case .fullScreenCover:
            contentViewController = MyUIHostingController(rootView: content(),onDisappear: onDisappear)
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
                                                              preferredCornerRadius: configuration.preferredCornerRadius,
                                                              onDisappear: onDisappear,
                                                              content: content())
        case .customBottomSheet:
            guard let configuration = configuration else { fatalError("configuration can't be nil in customBottomSheet style.") }
            contentViewController = BottomSheetViewController(detents: configuration.detents,
                                                              largestUndimmedDetentIdentifier: configuration.largestUndimmedDetentIdentifier,
                                                              prefersGrabberVisible: configuration.prefersGrabberVisible,
                                                              prefersScrollingExpandsWhenScrolledToEdge: configuration.prefersScrollingExpandsWhenScrolledToEdge,
                                                              prefersEdgeAttachedInCompactHeight: configuration.prefersEdgeAttachedInCompactHeight,
                                                              widthFollowsPreferredContentSizeWhenEdgeAttached: configuration.widthFollowsPreferredContentSizeWhenEdgeAttached,
                                                              detentIdentifier: detentIdentifier,
                                                              preferredCornerRadius: configuration.preferredCornerRadius,
                                                              onDisappear: onDisappear,
                                                              content: content())
        }

        viewController?.present(contentViewController, animated: animated, completion: afterPresent)
    }

    public init() {}
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
        /// BottomSheet配置
        /// - Parameters:
        ///   - detents: 允许的高度，默认[.medium(), .large()]，第一个为sheet初次显示的位置
        ///   - largestUndimmedDetentIdentifier: 交互遮罩尺寸。默认为nil(相当于.large)，如果设置为.medium，当显示半高时，Sheet下的视图可交互
        ///   - prefersGrabberVisible: 是否显示模态视图上方的抓取提示
        ///   - prefersScrollingExpandsWhenScrolledToEdge: 模态视图中的滚动是否会影响模态视图高度。如果想在半高时，顺利滚动，需设置为false
        ///   - prefersEdgeAttachedInCompactHeight: 模态视图是否以紧凑高度尺寸附加到屏幕的底部边缘
        ///   - widthFollowsPreferredContentSizeWhenEdgeAttached: 模态视图的宽度是否于视图控制器的首选内容大小相匹配
        ///   - preferredCornerRadius: 模态视图圆角值
        public init(detents: [UISheetPresentationController.Detent],
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

public struct SheetKitKey: EnvironmentKey {
    public static var defaultValue = SheetKit()
}

public extension EnvironmentValues {
    var sheetKit: SheetKit { self[SheetKitKey.self] }
}

// MARK: - UIHostingController

final class MyUIHostingController<Content: View>: UIHostingController<Content> {
    var onDisappear: (() -> Void)?
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDisappear?()
    }

    init(rootView: Content,onDisappear:(() -> Void)? = nil) {
        self.onDisappear = onDisappear
        super.init(rootView: rootView)
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
