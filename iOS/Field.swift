import UIKit

class Field: UITextView {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(4)
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: CGRect, usedRect: CGRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    final class Search: Field {
        private(set) weak var _cancel: UIButton!
        
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            textContainer.size.height = 35
            textContainer.size.width = 370
            textContainerInset = .init(top: 9, left: 40, bottom: 9, right: 40)
            layoutManager.ensureLayout(for: textContainer)
            accessibilityLabel = .key("Field.search")
            
            let icon = UIButton()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
            icon.setImage(UIImage(named: "search"), for: .normal)
            icon.imageView!.contentMode = .center
            icon.imageView!.clipsToBounds = true
            icon.isAccessibilityElement = true
            icon.accessibilityLabel = .key("Field.icon")
            addSubview(icon)
            
            let _cancel = UIButton()
            _cancel.translatesAutoresizingMaskIntoConstraints = false
            _cancel.setImage(UIImage(named: "delete"), for: .normal)
            _cancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            _cancel.isHidden = true
            _cancel.imageView!.contentMode = .center
            _cancel.imageView!.clipsToBounds = true
            _cancel.isAccessibilityElement = true
            _cancel.accessibilityLabel = .key("Field.cancel")
            addSubview(_cancel)
            self._cancel = _cancel
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 50).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            _cancel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            _cancel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            _cancel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            _cancel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        @objc private func cancel() {
            app.window!.endEditing(true)
            text = ""
        }
    }
    
    final class Name: Field {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            textContainerInset = .init(top: 7, left: 10, bottom: 7, right: 10)
            heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
            accessibilityLabel = .key("Field.name")
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    private init() {
        let storage = NSTextStorage()
        super.init(frame: .zero, textContainer: {
            $1.delegate = $1
            storage.addLayoutManager($1)
            $1.addTextContainer($0)
            $0.lineBreakMode = .byTruncatingHead
            return $0
        } (NSTextContainer(), Layout()))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        bounces = false
        isScrollEnabled = false
        textColor = .white
        tintColor = .halo
        font = .preferredFont(forTextStyle: .title2)
        keyboardType = .alphabet
        keyboardAppearance = .dark
        autocorrectionType = .yes
        spellCheckingType = .yes
        autocapitalizationType = .sentences
        isAccessibilityElement = true
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width += 3
        return rect
    }
}