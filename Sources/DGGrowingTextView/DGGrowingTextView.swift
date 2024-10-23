// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit
import Proton

open class DGTextView: UITextView, UITextViewDelegate {
    
    let _font: UIFont?
    let _lineHeight: CGFloat?
    let _textColor: UIColor?
    let _tintColor: UIColor?
    let _mentionForegroundColor: UIColor
    let _mension: String?
    
    public init(
        font: UIFont? = nil,
        lineHeight: CGFloat? = nil,
        textColor: UIColor? = nil,
        tintColor: UIColor? = nil,
        mentionForegroundColor: UIColor = .gray,
        mension: String? = nil
    ) {
        _font = font
        _lineHeight = lineHeight
        _textColor = textColor
        _tintColor = tintColor
        _mentionForegroundColor = mentionForegroundColor
        
        if let mension {
            if mension.contains("@") {
                _mension = mension
            } else {
                _mension = "@\(mension)"
            }
        } else {
            _mension = nil
        }
        
        super.init(frame: .zero, textContainer: nil)
        
        isEditable = true
        backgroundColor = .clear
        self.tintColor = tintColor
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
        
        if let mention = extractMention(from: text), mention == _mension {
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
    let textView: DGTextView
    
    public init(
        text: Binding<String>,
        placeholder: String? = nil,
        placeholderTextColor: UIColor? = .gray,
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
                    textView: textView,
                    textDidChange: { _ in }
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
    
    @State private var text: String = "@Nickname "
    let textView: DGTextView = {
        let view = DGTextView(font: .systemFont(ofSize: 30), lineHeight: 50, textColor: .white, tintColor: nil, mension: "Nickname")
        return view
    }()
    
    var body: some View {
        ExpandingTextView(
            text: $text,
            placeholder: nil,
            placeholderTextColor: nil,
            minHeight: 30,
            maxHeight: 150,
            textView: textView
        )
    }
}

#Preview {
    ExpandingTextViewPreview()
        .preferredColorScheme(.dark)
}
