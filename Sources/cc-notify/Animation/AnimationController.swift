import AppKit

final class AnimationController {
    private let window: OverlayWindow
    private let notificationView: NotificationView
    private let finalOrigin: NSPoint
    private var timer: Timer?
    private var startTime: TimeInterval = 0
    private var onComplete: (() -> Void)?

    // Timing
    private let entranceDuration: TimeInterval = 0.5
    private let idleDuration: TimeInterval = 3.5
    private let exitDuration: TimeInterval = 0.4
    private var totalDuration: TimeInterval { entranceDuration + idleDuration + exitDuration }

    // Positions
    private var startY: CGFloat = 0
    private var overshootY: CGFloat = 0
    private var finalY: CGFloat = 0
    private var exitY: CGFloat = 0

    init(window: OverlayWindow, notificationView: NotificationView, finalOrigin: NSPoint) {
        self.window = window
        self.notificationView = notificationView
        self.finalOrigin = finalOrigin

        self.finalY = finalOrigin.y
        self.overshootY = finalOrigin.y + 18
        self.startY = finalOrigin.y - window.frame.height - 80
        self.exitY = finalOrigin.y - window.frame.height - 80
    }

    func runFullSequence(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        self.startTime = CACurrentMediaTime()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        let elapsed = CACurrentMediaTime() - startTime

        if elapsed < entranceDuration {
            // Phase 1: Slide up with bounce
            let t = elapsed / entranceDuration
            let y = bounceIn(t: t)
            window.setFrameOrigin(NSPoint(x: finalOrigin.x, y: y))
            window.alphaValue = 1.0

        } else if elapsed < entranceDuration + idleDuration {
            // Phase 2: Idle — gentle bob on the crab sprite
            let idleElapsed = elapsed - entranceDuration
            notificationView.clawdView.phase = CGFloat(idleElapsed) * 0.8
            window.setFrameOrigin(finalOrigin)
            window.alphaValue = 1.0

        } else if elapsed < totalDuration {
            // Phase 3: Slide down + fade out
            let t = (elapsed - entranceDuration - idleDuration) / exitDuration
            let eased = easeIn(t: t)
            let y = finalY + (exitY - finalY) * eased
            window.setFrameOrigin(NSPoint(x: finalOrigin.x, y: y))
            window.alphaValue = CGFloat(1.0 - eased)

        } else {
            // Done
            timer?.invalidate()
            timer = nil
            onComplete?()
        }
    }

    // Bounce: overshoot then settle
    private func bounceIn(t: Double) -> CGFloat {
        let eased: Double
        if t < 0.7 {
            // Ease out to overshoot
            let sub = t / 0.7
            eased = 1.0 - pow(1.0 - sub, 3)
            let y = startY + (overshootY - startY) * eased
            return y
        } else {
            // Settle from overshoot to final
            let sub = (t - 0.7) / 0.3
            let settled = sub * sub * (3.0 - 2.0 * sub) // smoothstep
            let y = overshootY + (finalY - overshootY) * settled
            return y
        }
    }

    private func easeIn(t: Double) -> Double {
        return t * t
    }
}
