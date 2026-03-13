import AppKit

final class AnimationController {
    private let window: OverlayWindow
    private let notificationView: NotificationView
    private var idleTimer: Timer?
    private var bounceTimer: Timer?

    private let entranceDuration: TimeInterval = 0.55
    private let idleDuration: TimeInterval = 3.5
    private let exitDuration: TimeInterval = 0.45

    init(window: OverlayWindow, notificationView: NotificationView) {
        self.window = window
        self.notificationView = notificationView
    }

    func runFullSequence(onComplete: @escaping () -> Void) {
        // Position window at final location first to get the target
        window.positionInBottomRight()
        let finalOrigin = window.frame.origin

        // Start below the screen (slide up from bottom)
        let startOrigin = NSPoint(x: finalOrigin.x, y: finalOrigin.y - window.frame.height - 40)
        window.setFrameOrigin(startOrigin)
        window.alphaValue = 0

        // Phase 1: Slide up with overshoot (bounce effect)
        // First, quick fade in
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            window.animator().alphaValue = 1.0
        })

        // Spring-like bounce: slide up past target, then settle
        let overshootOrigin = NSPoint(x: finalOrigin.x, y: finalOrigin.y + 14)

        // Slide up to overshoot position
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = entranceDuration * 0.65
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrameOrigin(overshootOrigin)
        }, completionHandler: { [weak self] in
            guard let self = self else { return }
            // Settle back to final position
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = self.entranceDuration * 0.35
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.window.animator().setFrameOrigin(finalOrigin)
            }, completionHandler: { [weak self] in
                self?.startIdleAnimation(onComplete: onComplete)
            })
        })
    }

    private func startIdleAnimation(onComplete: @escaping () -> Void) {
        // Gentle breathing bob on the crab
        let startTime = CACurrentMediaTime()
        let bobFrequency: CGFloat = 0.8

        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let elapsed = CACurrentMediaTime() - startTime
            self.notificationView.clawdView.phase = CGFloat(elapsed) * bobFrequency
        }

        // After idle duration, exit
        DispatchQueue.main.asyncAfter(deadline: .now() + idleDuration) { [weak self] in
            self?.idleTimer?.invalidate()
            self?.idleTimer = nil
            self?.runExitAnimation(onComplete: onComplete)
        }
    }

    private func runExitAnimation(onComplete: @escaping () -> Void) {
        let currentOrigin = window.frame.origin
        let exitOrigin = NSPoint(x: currentOrigin.x, y: currentOrigin.y - window.frame.height - 40)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = exitDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0.0
            window.animator().setFrameOrigin(exitOrigin)
        }, completionHandler: {
            onComplete()
        })
    }
}
