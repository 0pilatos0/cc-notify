import AppKit

final class SpeechBubbleView: NSView {
    private let message: String
    private let style: NotificationStyle

    private let horizontalPadding: CGFloat = 20
    private let verticalPadding: CGFloat = 14
    private let cornerRadius: CGFloat = 10
    private let pointerHeight: CGFloat = 10
    private let pointerWidth: CGFloat = 16

    // Dark theme colors matching Clawd's background
    private let bgColor = NSColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0)
    private let borderColor = NSColor(red: 0.30, green: 0.30, blue: 0.30, alpha: 1.0)
    private let textColor = NSColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)

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

        return [
            .font: NSFont(name: "Menlo-Bold", size: 14)
                ?? NSFont.monospacedSystemFont(ofSize: 14, weight: .bold),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
        ]
    }

    private func textSize() -> NSSize {
        let attrString = NSAttributedString(string: message, attributes: textAttributes)
        let maxWidth: CGFloat = 240
        let boundingRect = attrString.boundingRect(
            with: NSSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
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
            width: ts.width + horizontalPadding * 2,
            height: ts.height + verticalPadding * 2 + pointerHeight
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let bubbleRect = NSRect(
            x: 1,
            y: 1,
            width: bounds.width - 2,
            height: bounds.height - pointerHeight - 1
        )

        // Shadow
        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -2),
            blur: 10,
            color: NSColor.black.withAlphaComponent(0.4).cgColor
        )

        // Bubble + pointer combined fill
        let bubblePath = NSBezierPath(roundedRect: bubbleRect, xRadius: cornerRadius, yRadius: cornerRadius)

        let pX = bubbleRect.midX - pointerWidth / 2
        let pointerPath = NSBezierPath()
        pointerPath.move(to: NSPoint(x: pX, y: bubbleRect.maxY - 1))
        pointerPath.line(to: NSPoint(x: pX + pointerWidth / 2, y: bubbleRect.maxY + pointerHeight))
        pointerPath.line(to: NSPoint(x: pX + pointerWidth, y: bubbleRect.maxY - 1))

        let combinedPath = NSBezierPath()
        combinedPath.append(bubblePath)
        combinedPath.append(pointerPath)

        bgColor.setFill()
        combinedPath.fill()
        context.restoreGState()

        // Border
        borderColor.setStroke()
        bubblePath.lineWidth = 1.5
        bubblePath.stroke()

        // Pointer border
        let pBorder = NSBezierPath()
        pBorder.move(to: NSPoint(x: pX + 1, y: bubbleRect.maxY))
        pBorder.line(to: NSPoint(x: pX + pointerWidth / 2, y: bubbleRect.maxY + pointerHeight))
        pBorder.line(to: NSPoint(x: pX + pointerWidth - 1, y: bubbleRect.maxY))
        pBorder.lineWidth = 1.5
        borderColor.setStroke()
        pBorder.stroke()

        // Cover seam
        let coverPath = NSBezierPath()
        coverPath.move(to: NSPoint(x: pX + 2, y: bubbleRect.maxY))
        coverPath.line(to: NSPoint(x: pX + pointerWidth - 2, y: bubbleRect.maxY))
        coverPath.lineWidth = 3
        bgColor.setStroke()
        coverPath.stroke()

        // Accent line under text — uses the Clawd orange
        let accentColor = NSColor(red: 215.0/255.0, green: 119.0/255.0, blue: 87.0/255.0, alpha: 0.6)
        let accentY = bubbleRect.maxY - 6
        let accentPath = NSBezierPath()
        accentPath.move(to: NSPoint(x: bubbleRect.minX + horizontalPadding, y: accentY))
        accentPath.line(to: NSPoint(x: bubbleRect.maxX - horizontalPadding, y: accentY))
        accentPath.lineWidth = 2
        accentColor.setStroke()
        accentPath.stroke()

        // Text
        let ts = textSize()
        let textRect = NSRect(
            x: bubbleRect.minX + horizontalPadding,
            y: bubbleRect.minY + verticalPadding,
            width: ts.width,
            height: ts.height
        )
        message.draw(in: textRect, withAttributes: textAttributes)
    }
}
