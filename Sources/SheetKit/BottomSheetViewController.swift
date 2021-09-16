//
//  BottomSheetViewController.swift
//  SheetManager
//
//  Created by Yang Xu on 2021/9/15.
//
// Code from https://github.com/adamfootdev/BottomSheet

import SwiftUI
import UIKit

final class BottomSheetViewController<Content: View>: UIViewController, UISheetPresentationControllerDelegate {
    private let detents: [UISheetPresentationController.Detent]
    private let largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    private let prefersGrabberVisible: Bool
    private let prefersScrollingExpandsWhenScrolledToEdge: Bool
    private let prefersEdgeAttachedInCompactHeight: Bool
    private let widthFollowsPreferredContentSizeWhenEdgeAttached: Bool
    private var detentIdentifier: Binding<UISheetPresentationController.Detent.Identifier>?
    private let preferredCornerRadius: CGFloat?
    private let notificationName: Notification.Name
    private let onDisappear: (() -> Void)?
    private let contentView: UIHostingController<Content>

    public init(
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersGrabberVisible: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        detentIdentifier: Binding<UISheetPresentationController.Detent.Identifier>? = nil,
        preferredCornerRadius: CGFloat?,
        notificationName: Notification.Name = .bottomSheetDetentIdentifierDidChanged,
        onDisappear: (() -> Void)? = nil,
        content: Content
    ) {
        self.detents = detents
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.detentIdentifier = detentIdentifier
        self.preferredCornerRadius = preferredCornerRadius
        self.notificationName = notificationName
        self.onDisappear = onDisappear
        contentView = UIHostingController(rootView: content)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        addChild(contentView)
        view.addSubview(contentView.view)

        contentView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = detents
            presentationController.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
            presentationController.prefersGrabberVisible = prefersGrabberVisible
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
            presentationController.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
            presentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
            presentationController.preferredCornerRadius = preferredCornerRadius
            presentationController.delegate = self
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDisappear?()
    }

    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let selectedDetentIdentifier = sheetPresentationController.selectedDetentIdentifier else { return }
        detentIdentifier?.wrappedValue = selectedDetentIdentifier
        NotificationCenter.default.post(name: .bottomSheetDetentIdentifierDidChanged, object: selectedDetentIdentifier)
    }
}

public extension Notification.Name {
    static let bottomSheetDetentIdentifierDidChanged = Notification.Name("bottomSheetDetentIdentifierDidChanged")
}
