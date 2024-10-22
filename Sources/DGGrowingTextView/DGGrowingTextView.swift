// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

struct WrappedTextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    let font: UIFont?
    let lineHeight: CGFloat?
    let textColor: UIColor?
    let textDidChange: (UITextView) -> Void
    let tintColor: UIColor?

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = true
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.tintColor = tintColor
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        if let font {
            attributes[.font] = font
        }
        
        if let lineHeight {
            attributes[.paragraphStyle] = {
                let paragraph = NSMutableParagraphStyle()
                paragraph.minimumLineHeight = lineHeight
                paragraph.maximumLineHeight = lineHeight
                return paragraph
            }()
        }
        
        if let textColor {
            attributes[.foregroundColor] = textColor
        }
        
        view.typingAttributes = attributes
        
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = self.text
        DispatchQueue.main.async {
            self.textDidChange(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, textDidChange: textDidChange)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        let textDidChange: (UITextView) -> Void

        init(text: Binding<String>, textDidChange: @escaping (UITextView) -> Void) {
            self._text = text
            self.textDidChange = textDidChange
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
            self.textDidChange(textView)
        }
    }
}

public struct ExpandingTextView: View {
    @Binding var text: String
    
    @State private var height: CGFloat?
    
    let placeholder: String?
    let placeholderTextColor: UIColor?
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let font: UIFont?
    let lineHeight: CGFloat?
    let textColor: UIColor?
    let tintColor: UIColor?
    
    public init(
        text: Binding<String>,
        placeholder: String? = nil,
        placeholderTextColor: UIColor? = .gray,
        minHeight: CGFloat = 150,
        maxHeight: CGFloat = 1000,
        font: UIFont? = nil,
        lineHeight: CGFloat? = nil,
        textColor: UIColor? = .label,
        tintColor: UIColor? = nil
    ) {
        _text = text
        self.placeholder = placeholder
        self.placeholderTextColor = placeholderTextColor
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.font = font
        self.lineHeight = lineHeight
        self.textColor = textColor
        self.tintColor = tintColor
    }

    public var body: some View {
        ZStack {
            WrappedTextView(
                text: $text,
                font: font,
                lineHeight: lineHeight,
                textColor: textColor,
                textDidChange: self.textDidChange,
                tintColor: tintColor
            )
            .frame(height: height ?? minHeight)
            
            if text.isEmpty, let placeholder {
                WrappedTextView(
                    text: .constant(placeholder),
                    font: font,
                    lineHeight: lineHeight,
                    textColor: placeholderTextColor,
                    textDidChange: self.textDidChange,
                    tintColor: tintColor
                )
                .frame(height: height ?? minHeight)
                .disabled(true)
            }
        }
        
    }

    private func textDidChange(_ textView: UITextView) {
        var height = max(textView.contentSize.height, minHeight)
        height = min(height, maxHeight)
        self.height = height
    }
}
