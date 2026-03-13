import AppKit

final class NotificationView: NSView {
    let clawdView: ClawdView
    let speechBubbleView: SpeechBubbleView

    private let spacing: CGFloat = 2
    private let margin: CGFloat = 16

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

        // Center Clawd horizontally, bubble centered above
        let totalWidth = max(bubbleSize.width, clawdSize.width)
        let bubbleX = margin + (totalWidth - bubbleSize.width) / 2
        let clawdX = margin + (totalWidth - clawdSize.width) / 2

        speechBubbleView.frame = NSRect(
            x: bubbleX,
            y: margin,
            width: bubbleSize.width,
            height: bubbleSize.height
        )

        clawdView.frame = NSRect(
            x: clawdX,
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
