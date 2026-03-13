import AppKit

final class NotificationView: NSView {
    let clawdView: ClawdView
    let speechBubbleView: SpeechBubbleView

    private let spacing: CGFloat = 0
    private let margin: CGFloat = 16  // extra margin so shadows aren't clipped

    init(style: NotificationStyle, message: String) {
        self.clawdView = ClawdView()
        self.clawdView.expression = style.expression
        self.speechBubbleView = SpeechBubbleView(message: message, style: style)
        super.init(frame: .zero)

        wantsLayer = true
        addSubview(speechBubbleView)
        addSubview(clawdView)

        layoutSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override var isFlipped: Bool { true }

    private func layoutSubviews() {
        let bubbleSize = speechBubbleView.intrinsicContentSize
        let clawdSize = clawdView.intrinsicContentSize

        // Speech bubble at top, centered horizontally with margin
        speechBubbleView.frame = NSRect(
            x: margin,
            y: margin,
            width: bubbleSize.width,
            height: bubbleSize.height
        )

        // Clawd below the bubble, right-aligned (under the pointer)
        let clawdX = margin + bubbleSize.width - clawdSize.width - 14
        clawdView.frame = NSRect(
            x: max(clawdX, margin),
            y: margin + bubbleSize.height + spacing,
            width: clawdSize.width,
            height: clawdSize.height
        )
    }

    override var intrinsicContentSize: NSSize {
        let bubbleSize = speechBubbleView.intrinsicContentSize
        let clawdSize = clawdView.intrinsicContentSize
        return NSSize(
            width: max(bubbleSize.width, clawdSize.width) + margin * 2,
            height: bubbleSize.height + spacing + clawdSize.height + margin * 2
        )
    }

    override var fittingSize: NSSize {
        return intrinsicContentSize
    }
}
