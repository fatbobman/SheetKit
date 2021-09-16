# SheetKit

SheetKit is an extension library for SwiftUI sheets.

[中文版说明 with Picture](https://www.fatbobman.com/posts/sheetKit/)

## What is SheetKit ##

SheetKit is a library of extensions for SwiftUI modal views. It provides several convenient display and cancel methods for modal views, as well as several View Extensions for modal views.

The main reasons for developing SheetKit.

* Convenient Deep link calls
  SwiftUI provides the onOpenURL method to make it very easy for applications to respond to Deep Link, but in practice, this is not as easy as expected. The main reason for this is that the important view presentation modes in SwiftUI: NavigationView, Sheet, etc. do not have the ability to be reset quickly and easily. It is difficult to instantly set the application to the view state we want with a couple of lines of code.

* Centralised management of modal views
  SwiftUI usually uses .sheets to create modal views, which is very intuitive for simple applications, but if the application logic is complex and requires many modal views, this can make the code very messy and difficult to organize. In this case, we usually manage all the modal views centrally and call them all together. See my previous article - Popping up different Sheets on demand in SwiftUI.

* The new UISheetPresentationController
  In WWDC 2021, Apple brought the long-awaited half-height modal view to everyone. The SheetKit makes up for it for now, but perhaps in a bit of a hurry, as there is no SwiftUI version of this popular interaction, only UIKit support. Both sheets, fullScreenCover and bottomSheet (half-height modal view) are fully supported and managed in one place.

## System requirements##

iOS 15

Swift 5.5

XCode 13.0 +


## How to use ##

### present ###

```swift
Button("show sheet"){
   SheetKit().present{
     Text("Hello world")
   }
}
```

or 

```swift
@Environment(\.sheetKit) var sheetKit

Button("show sheet"){
   sheetKit.present{
     Text("Hello world")
   }
}
```

support multiSheet

```swift
@Environment(\.sheetKit) var sheetKit

Button("show sheet"){
   sheetKit.present{
     Button("show full sheet"){
       sheetKit.present(with:.fullScreenCover){
         Text("Hello world")
       }
     }
   }
}
```

### sheet style ###

three types sytle:
* sheet
* fullScreenCover
* bottomSheet

```swift
sheetKit.present(with: .bottomSheet){
  Text("Hello world")
}
```

custom bottomSheet

```swift
let configuration = SheetKit.BottomSheetConfiguration(  detents: [.medium(),.large()],
                                                        largestUndimmedDetentIdentifier: .medium,
                                                        prefersGrabberVisible: true,
                                                        prefersScrollingExpandsWhenScrolledToEdge: false,
                                                        prefersEdgeAttachedInCompactHeight: false,
                                                        widthFollowsPreferredContentSizeWhenEdgeAttached: true,
                                                        preferredCornerRadius: 100)

sheetKit.present(with: .customBottomSheet,configuration: configuration) {
  Text("Hello world")
}
```

get notice when bottomSheet modal changed

```swift
@State var detent:UISheetPresentationController.Detent.Identifier = .medium

Button("Show"){
  sheetKit.present(with: .bottomSheet,detentIdentifier: $detent){
    Text("Hello worl")
  }
}
.onChange(of: detent){ value in
    print(value)
}
```

or 

```swift
@State var publisher = NotificationCenter.default.publisher(for: .bottomSheetDetentIdentifierDidChanged, object: nil)

.onReceive(publisher){ notification in
       guard let obj = notification.object else {return}
       print(obj)
}
```

### dismissAllSheets ###

```swift
 SheetKit().dismissAllSheets(animated: false, completion: {
        print("sheet has dismiss")
    })
```

### dismiss ###

```swift
 SheetKit().dismiss()
```

### interactiveDismissDisabled ###

SwiftUI 3.0's interactiveDismissDisabled enhancement adds the ability to be notified when a user uses a gesture to cancel, on top of the ability to control whether gesture cancellation is allowed via code.

```swift
struct ContentView: View {
    @State var sheet = false
    var body: some View {
        VStack {
            Button("show sheet") {
                sheet.toggle()
            }
        }
        .sheet(isPresented: $sheet) {
            SheetView()
        }
    }
}

struct SheetView: View {
    @State var disable = false
    @State var attempToDismiss = UUID()
    var body: some View {
        VStack {
            Button("disable: \(disable ? "true" : "false")") {
                disable.toggle()
            }
            .interactiveDismissDisabled(disable, attempToDismiss: $attempToDismiss)
        }
        .onChange(of: attempToDismiss) { _ in
            print("try to dismiss sheet")
        }
    }
}
```

### clearBackground ###

Set the background of the modal view to transparent. In SwiftUI 3.0, it is already possible to generate various hair-glass effects using the native API. However, the hair glass effect is only visible if the background of the modal view is set to transparent.

```swift
ZStack {
            Rectangle().fill(LinearGradient(colors: [.red, .green, .pink, .blue, .yellow, .cyan, .gray], startPoint: .topLeading, endPoint: .bottomTrailing))
            Button("Show bottomSheet") {
                sheetKit.present(with: .bottomSheet, afterPresent: { print("presented") }, onDisappear: { print("disappear") }, detentIdentifier: $detent) {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                        VStack {
                            Text("Hello world")
                            Button("dismiss all") {
                                SheetKit().dismissAllSheets(animated: true, completion: {
                                    print("sheet has dismiss")
                                })
                            }
                        }
                    }
                    .clearBackground()
                    .ignoresSafeArea()
                }
            }
            .foregroundColor(.white)
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.green)
        }
        .ignoresSafeArea()
```
