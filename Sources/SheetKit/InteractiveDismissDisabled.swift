//
//  File.swift
//  
//
//  Created by Yang Xu on 2021/9/16.
//

import SwiftUI
import UIKit

struct SetSheetDelegate: UIViewRepresentable {
    let delegate: SheetDelegate

    init(isDisable: Bool, attempToDismiss: Binding<UUID>) {
        delegate = SheetDelegate(isDisable, attempToDismiss: attempToDismiss)
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if uiView.parentViewController?.sheetPresentationController != nil {
                weak var sheetController = uiView.parentViewController?.sheetPresentationController
                delegate.originalDelegate = sheetController?.delegate
                sheetController?.delegate = delegate
            } else {
                uiView.parentViewController?.presentationController?.delegate = delegate
            }
        }
    }
}

final class SheetDelegate: NSObject, UIAdaptivePresentationControllerDelegate, UISheetPresentationControllerDelegate {
    var isDisable: Bool
    @Binding var attempToDismiss: UUID
    weak var originalDelegate:UISheetPresentationControllerDelegate?

    init(_ isDisable: Bool, attempToDismiss: Binding<UUID> = .constant(UUID())) {
        self.isDisable = isDisable
        _attempToDismiss = attempToDismiss
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        !isDisable
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        attempToDismiss = UUID()
    }

    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        originalDelegate?.sheetPresentationControllerDidChangeSelectedDetentIdentifier?(sheetPresentationController)
    }
}

public extension View {
    func interactiveDismissDisabled(_ isDisable: Bool, attempToDismiss: Binding<UUID>) -> some View {
        background(SetSheetDelegate(isDisable: isDisable, attempToDismiss: attempToDismiss))
    }
}

public extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

