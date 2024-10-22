# DGGrowingTextView
Provides a SwiftUI multi-line TextView implementation including support for auto-sizing. (iOS)

## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `DGGrowingTextView` as a dependency is as easy as adding it to the dependencies value of your Package.swift or the Package list in Xcode.

```
dependencies: [
   .package(url: "https://github.com/donggyushin/DGGrowingTextView.git", .upToNextMajor(from: "1.0.0"))
]
```

Normally you'll want to depend on the DGGrowingTextView target:

```
.product(name: "DGGrowingTextView", package: "DGGrowingTextView")
```

## Usage
```swift
DGGrowingTextView(
            text: $text,
            placeholder: "placeholder",
            minHeight: 21,
            maxHeight: 84,
            font: .pretendard(.regular, size: 15),
            lineHeight: 21,
            textColor: .red
        )
```