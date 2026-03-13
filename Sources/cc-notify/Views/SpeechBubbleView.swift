import AppKit

final class SpeechBubbleView: NSView {
    private let message: String
    private let style: NotificationStyle

    private let horizontalPadding: CGFloat = 18
    private let verticalPadding: CGFloat = 12
    private let cornerRadius: CGFloat = 14
    private let pointerHeight: CGFloat = 12
    private let pointerWidth: CGFloat = 18

    init(message: String, style: NotificationStyle) {
        self.message = message
        self.style = style
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override var isFlipped: Bool { true }

    private var textAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 2

        return [
            .font: NSFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor: NSColor(white: 0.12, alpha: 1.0),
            .paragraphStyle: paragraphStyle,
        ]
    }

    private func textSize() -> NSSize {
        let attrString = NSAttributedString(string: message, attributes: textAttributes)
        let maxWidth: CGFloat = 220
        let boundingRect = attrString.boundingRect(
            with: NSSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return NSSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
    }

    override var intrinsicContentSize: NSSize {
        let ts = textSize()
        return NSSize(
            width: ts.width + horizontalPadding * 2 + 6,
            height: ts.height + verticalPadding * 2 + pointerHeight
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let inset: CGFloat = 2
        let bubbleRect = NSRect(
            x: inset,
            y: inset,
            width: bounds.width - inset * 2,
            height: bounds.height - pointerHeight - inset
        )

        // --- Shadow ---
        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -3),
            blur: 12,
            color: NSColor.black.withAlphaComponent(0.2).cgColor
        )

        // --- Bubble body ---
        let bubblePath = NSBezierPath(roundedRect: bubbleRect, xRadius: cornerRadius, yRadius: cornerRadius)

        // Pointer triangle pointing down-right toward crab
        let pX = bubbleRect.maxX - 36
        let pointerPath = NSBezierPath()
        pointerPath.move(to: NSPoint(x: pX, y: bubbleRect.maxY - 1))
        pointerPath.line(to: NSPoint(x: pX + 10, y: bubbleRect.maxY + pointerHeight))
        pointerPath.line(to: NSPoint(x: pX + pointerWidth, y: bubbleRect.maxY - 1))

        // Combine bubble + pointer into one shape
        let combinedPath = NSBezierPath()
        combinedPath.append(bubblePath)
        combinedPath.append(pointerPath)

        // Fill white
        NSColor.white.setFill()
        combinedPath.fill()
        context.restoreGState()

        // --- Border ---
        let borderColor = style.bubbleBorderColor
        borderColor.setStroke()
        bubblePath.lineWidth = 1.5
        bubblePath.stroke()

        // Pointer border (just the two outer edges)
        let pointerBorderPath = NSBezierPath()
        pointerBorderPath.move(to: NSPoint(x: pX + 1, y: bubbleRect.maxY))
        pointerBorderPath.line(to: NSPoint(x: pX + 10, y: bubbleRect.maxY + pointerHeight))
        pointerBorderPath.line(to: NSPoint(x: pX + pointerWidth - 1, y: bubbleRect.maxY))
        pointerBorderPath.lineWidth = 1.5
        borderColor.setStroke()
        pointerBorderPath.stroke()

        // White cover line to hide where pointer meets bubble
        let coverPath = NSBezierPath()
        coverPath.move(to: NSPoint(x: pX + 2, y: bubbleRect.maxY))
        coverPath.line(to: NSPoint(x: pX + pointerWidth - 2, y: bubbleRect.maxY))
        coverPath.lineWidth = 3
        NSColor.white.setStroke()
        coverPath.stroke()

        // --- Accent bar (left edge) ---
        let accentRect = NSRect(
            x: bubbleRect.minX + 1,
            y: bubbleRect.minY + cornerRadius,
            width: 4,
            height: bubbleRect.height - cornerRadius * 2
        )
        style.accentColor.setFill()
        NSBezierPath(roundedRect: accentRect, xRadius: 2, yRadius: 2).fill()

        // --- Text ---
        let ts = textSize()
        let textRect = NSRect(
            x: bubbleRect.minX + horizontalPadding + 4,
            y: bubbleRect.minY + verticalPadding,
            width: ts.width,
            height: ts.height
        )
        message.draw(in: textRect, withAttributes: textAttributes)
    }
}
