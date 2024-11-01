// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

public extension NSAttributedString {
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}

open class DGTextView: UITextView, UITextViewDelegate {
    
    let _font: UIFont?
    let _lineHeight: CGFloat?
    let _textColor: UIColor?
    let _tintColor: UIColor?
    let _mentionForegroundColor: UIColor
    let _mention: String?
    
    let _textViewDidBeginEditing: ((UITextView) -> Void)?
    let _textViewDidEndEditing: ((UITextView) -> Void)?
    
    public init(
        font: UIFont? = nil,
        lineHeight: CGFloat? = nil,
        textColor: UIColor? = nil,
        tintColor: UIColor? = nil,
        mentionForegroundColor: UIColor = .gray,
        mention: String? = nil,
        textViewDidBeginEditing: ((UITextView) -> Void)? = nil,
        textViewDidEndEditing: ((UITextView) -> Void)? = nil
    ) {
        
        _font = font
        _lineHeight = lineHeight
        _textColor = textColor
        _tintColor = tintColor
        _mentionForegroundColor = mentionForegroundColor
        _textViewDidBeginEditing = textViewDidBeginEditing
        _textViewDidEndEditing = textViewDidEndEditing
        
        if let mention {
            if mention.contains("@") {
                _mention = mention
            } else {
                _mention = "@\(mention)"
            }
        } else {
            _mention = nil
        }
        
        super.init(frame: .zero, textContainer: nil)
        self.font = font
        isEditable = true
        backgroundColor = .clear
        self.tintColor = tintColor
        textContainerInset = .zero
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getAttributedString(text: String) -> NSMutableAttributedString {
        
        let attrString = NSMutableAttributedString(string: text)
        
        if let font = _font {
            attrString.addAttribute(.font, value: font, range: attrString.fullRange)
        }
        
        if let lineHeight = _lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: attrString.fullRange)
        }
        
        if let textColor = _textColor {
            attrString.addAttribute(.foregroundColor, value: textColor, range: attrString.fullRange)
        }
        
        if let mention = extractMention(from: text), mention == _mention {
            let nsstring = text as NSString
            attrString.addAttribute(.foregroundColor, value: _mentionForegroundColor, range: nsstring.range(of: mention))
        }
        
        return attrString
    }
}

public func extractMention(from text: String) -> String? {
    // 공백으로 구분된 첫 번째 단어를 추출
    if let firstWord = text.split(separator: " ").first {
        let firstWordString = String(firstWord)
        
        // 첫 번째 단어가 "@"로 시작하면 해당 단어 반환
        if firstWordString.starts(with: "@") {
            return firstWordString
        }
    }
    return nil
}


struct WrappedTextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    let textView: DGTextView
    let textDidChange: (UITextView) -> Void

    func makeUIView(context: Context) -> UITextView {
        let view = textView
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = textView.getAttributedString(text: self.text)
        DispatchQueue.main.async {
            self.textDidChange(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            text: $text,
            textDidChange: textDidChange,
            textDidBeginEditing: textView._textViewDidBeginEditing,
            textViewDidEndEditing: textView._textViewDidEndEditing
        )
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        let textDidChange: (UITextView) -> Void
        let textDidBeginEditing: ((UITextView) -> Void)?
        let textViewDidEndEditing: ((UITextView) -> Void)?

        init(
            text: Binding<String>,
            textDidChange: @escaping (UITextView) -> Void,
            textDidBeginEditing: ((UITextView) -> Void)?,
            textViewDidEndEditing: ((UITextView) -> Void)?
        ) {
            self._text = text
            self.textDidChange = textDidChange
            self.textDidBeginEditing = textDidBeginEditing
            self.textViewDidEndEditing = textViewDidEndEditing
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textDidBeginEditing?(textView)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            textViewDidEndEditing?(textView)
        }
    }
}

public struct DGGrowingTextView: View {
    @Binding var text: String
    
    @State private var height: CGFloat?
    
    let placeholder: String?
    let placeholderTextColor: UIColor
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let textView: DGTextView
    
    let textViewForPlaceholder: DGTextView
    
    public init(
        text: Binding<String>,
        placeholder: String? = nil,
        placeholderTextColor: UIColor = .gray,
        minHeight: CGFloat = 150,
        maxHeight: CGFloat = 1000,
        textView: DGTextView
    ) {
        _text = text
        self.placeholder = placeholder
        self.placeholderTextColor = placeholderTextColor
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.textView = textView
        
        textViewForPlaceholder = .init(
            font: textView._font,
            lineHeight: textView._lineHeight,
            textColor: placeholderTextColor,
            tintColor: nil
        )
    }

    public var body: some View {
        ZStack {
            WrappedTextView(
                text: $text,
                textView: textView,
                textDidChange: self.textDidChange
            )
            .frame(height: height ?? minHeight)
            
            if text.isEmpty, let placeholder {
                WrappedTextView(
                    text: .constant(placeholder),
                    textView: textViewForPlaceholder,
                    textDidChange: self.textDidChange
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

private struct ExpandingTextViewPreview: View {
    
    @State private var text: String = ""
    let textView: DGTextView = {
        let view = DGTextView(
            font: .systemFont(ofSize: 15),
            lineHeight: 20,
            textColor: .white,
            tintColor: nil,
            mention: "Nickname"
        )
        return view
    }()
    
    var body: some View {
        DGGrowingTextView(
            text: $text,
            placeholder: "Hello World",
            minHeight: 30,
            maxHeight: 150,
            textView: textView
        )
        .onAppear {
            textView.becomeFirstResponder()
        }
    }
}

#Preview {
    ExpandingTextViewPreview()
        .preferredColorScheme(.dark)
}
