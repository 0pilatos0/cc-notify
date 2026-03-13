import AppKit

enum NotifyApp {
    static func launch(style: NotificationStyle, message: String) {
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)

        let notificationView = NotificationView(style: style, message: message)
        let viewSize = notificationView.fittingSize

        fputs("[cc-notify] View size: \(viewSize)\n", stderr)

        let window = OverlayWindow(contentRect: NSRect(origin: .zero, size: viewSize))
        window.contentView = notificationView
        window.positionInBottomRight()

        // Start fully visible (no animation for now, let's just confirm it shows)
        window.alphaValue = 1.0
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        app.activate(ignoringOtherApps: true)

        fputs("[cc-notify] Window frame: \(window.frame)\n", stderr)
        fputs("[cc-notify] Window visible: \(window.isVisible)\n", stderr)
        fputs("[cc-notify] App active: \(app.isActive)\n", stderr)

        // NO dock icon hiding for now — keep .regular

        // Hold for 5 seconds then exit
        let runLoop = RunLoop.current
        let deadline = Date(timeIntervalSinceNow: 5.0)
        while Date() < deadline {
            runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.016))
        }

        fputs("[cc-notify] Done, closing\n", stderr)
        window.close()
    }
}
