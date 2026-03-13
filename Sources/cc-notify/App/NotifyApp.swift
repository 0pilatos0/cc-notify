import AppKit

enum NotifyApp {
    static func launch(style: NotificationStyle, message: String) {
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)

        let notificationView = NotificationView(style: style, message: message)
        let viewSize = notificationView.fittingSize

        let window = OverlayWindow(contentRect: NSRect(origin: .zero, size: viewSize))
        window.contentView = notificationView

        // Position off-screen (below bottom), fully opaque
        window.positionInBottomRight()
        let finalOrigin = window.frame.origin
        let startOrigin = NSPoint(x: finalOrigin.x, y: finalOrigin.y - window.frame.height - 80)
        window.setFrameOrigin(startOrigin)
        window.alphaValue = 1.0
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        app.activate(ignoringOtherApps: true)

        // Run animation
        let animationController = AnimationController(window: window, notificationView: notificationView, finalOrigin: finalOrigin)
        var shouldTerminate = false

        // Let the window render one frame
        let runLoop = RunLoop.current
        runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.05))

        animationController.runFullSequence {
            shouldTerminate = true
        }

        while !shouldTerminate {
            runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.016))
        }

        window.close()
    }
}
