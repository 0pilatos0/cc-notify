import AppKit

enum ClawdExpression {
    case happy
    case alert
}

enum NotificationStyle {
    case done
    case attention

    var defaultMessages: [String] {
        switch self {
        case .done:
            return ["All done!", "I'm finished!", "Done over here!", "Task complete!", "That's a wrap!"]
        case .attention:
            return ["I have a question!", "Need your input!", "Hey, over here!", "Quick question!", "Waiting on you!"]
        }
    }

    var accentColor: NSColor {
        switch self {
        case .done:
            return NSColor(red: 0.30, green: 0.78, blue: 0.47, alpha: 1.0)  // green
        case .attention:
            return NSColor(red: 0.843, green: 0.467, blue: 0.341, alpha: 1.0)  // official Clawd orange
        }
    }

    var bubbleBorderColor: NSColor {
        switch self {
        case .done:
            return NSColor(red: 0.24, green: 0.64, blue: 0.38, alpha: 0.5)
        case .attention:
            return NSColor(red: 0.70, green: 0.38, blue: 0.27, alpha: 0.5)
        }
    }

    var expression: ClawdExpression {
        switch self {
        case .done: return .happy
        case .attention: return .alert
        }
    }

    static func from(eventString: String) -> NotificationStyle {
        switch eventString.lowercased() {
        case "notification", "attention", "question":
            return .attention
        default:
            return .done
        }
    }
}
