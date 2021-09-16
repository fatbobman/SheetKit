//
//  File.swift
//
//
//  Created by Yang Xu on 2021/9/16.
//

import Foundation
import SwiftUI

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

public extension View{
    @ViewBuilder
    func clearBackground(_ enable:Bool = true) -> some View{
        if enable{
            background(BackgroundCleanerView())
        }
        else {
            self
        }
    }
}
