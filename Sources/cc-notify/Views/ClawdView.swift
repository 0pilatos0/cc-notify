import AppKit

final class ClawdView: NSView {
    var expression: ClawdExpression = .happy {
        didSet { needsDisplay = true }
    }

    var phase: CGFloat = 0.0 {
        didSet { needsDisplay = true }
    }

    // The EXACT official Clawd Unicode art from Claude Code terminal
    private let clawdArt = " ▐▛███▜▌ \n▝▜█████▛▘\n ▐▐   ▌▌ "
    private let clawdAlertArt = " ▐▛███▜▌ \n▝▜█████▛▘\n ▐▐   ▌▌ "

    // Official Clawd color: RGB(215, 119, 87)
    private let clawdColor = NSColor(red: 215.0/255.0, green: 119.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    private let bgColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)

    private let fontSize: CGFloat = 36.0
    private let padding: CGFloat = 12.0
    private let cornerRadius: CGFloat = 10.0

    private var font: NSFont {
        return NSFont(name: "Menlo-Bold", size: fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)
    }

    private var textAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        // Line height must exactly match font metrics for block chars to connect
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 0.80
        paragraphStyle.paragraphSpacing = 0

        return [
            .font: font,
            .foregroundColor: clawdColor,
            .paragraphStyle: paragraphStyle,
        ]
    }

    private func textSize() -> NSSize {
        let art = expression == .alert ? clawdAlertArt : clawdArt
        let attrString = NSAttributedString(string: art, attributes: textAttributes)
        let boundingRect = attrString.boundingRect(
            with: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return NSSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }

    override var intrinsicContentSize: NSSize {
        let ts = textSize()
        return NSSize(
            width: ts.width + padding * 2,
            height: ts.height + padding * 2
        )
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let bobOffset = sin(phase * .pi * 2) * 2.0

        // Draw dark rounded background
        let bgRect = NSRect(
            x: 0,
            y: bobOffset,
            width: bounds.width,
            height: bounds.height
        )
        let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
        bgColor.setFill()
        bgPath.fill()

        // Draw the Unicode art
        let art = expression == .alert ? clawdAlertArt : clawdArt
        let ts = textSize()
        let textRect = NSRect(
            x: (bounds.width - ts.width) / 2,
            y: padding + bobOffset,
            width: ts.width,
            height: ts.height
        )
        art.draw(in: textRect, withAttributes: textAttributes)
    }
}
