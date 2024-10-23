# DGGrowingTextView
Provides a SwiftUI multi-line TextView implementation including support for auto-sizing. (iOS)

Supports custom font, lineHeight feature.

Also supports very simple mention effect very easily.

## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `DGGrowingTextView` as a dependency is as easy as adding it to the dependencies value of your Package.swift or the Package list in Xcode.

```
dependencies: [
   .package(url: "https://github.com/donggyushin/DGGrowingTextView.git", .upToNextMajor(from: "1.1.3"))
]
```

Normally you'll want to depend on the DGGrowingTextView target:

```
.product(name: "DGGrowingTextView", package: "DGGrowingTextView")
```

## Usage
```swift
private struct ExpandingTextViewPreview: View {
    
    @State private var text: String = "@Nickname "
    let textView: DGTextView = {
        let view = DGTextView(
            font: .systemFont(ofSize: 30),
            lineHeight: 50,
            textColor: .white,
            tintColor: nil,
            mention: "Nickname"
        )
        return view
    }()
    
    var body: some View {
        DGGrowingTextView(
            text: $text,
            placeholder: nil,
            placeholderTextColor: nil,
            minHeight: 30,
            maxHeight: 150,
            textView: textView
        )
    }
}

```

<img src="https://github.com/user-attachments/assets/95378a87-d448-4cc1-8f14-0d96b7b00820" width=300 />
