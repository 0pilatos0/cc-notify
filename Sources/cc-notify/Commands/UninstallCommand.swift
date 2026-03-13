import ArgumentParser
import Foundation

struct UninstallCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Remove cc-notify hooks from Claude Code settings"
    )

    mutating func run() throws {
        let settingsURL = InstallCommand.settingsURL()
        var settings = InstallCommand.readSettings(from: settingsURL)

        guard var hooks = settings["hooks"] as? [String: Any] else {
            print("No hooks found in ~/.claude/settings.json")
            return
        }

        var removedCount = 0

        for event in ["Stop", "Notification"] {
            guard var eventArray = hooks[event] as? [[String: Any]] else { continue }

            // Remove cc-notify entries from each matcher group
            for (groupIdx, group) in eventArray.enumerated().reversed() {
                if var groupHooks = group["hooks"] as? [[String: Any]] {
                    groupHooks.removeAll { hook in
                        if let cmd = hook["command"] as? String, cmd.contains("cc-notify") {
                            removedCount += 1
                            return true
                        }
                        return false
                    }

                    if groupHooks.isEmpty {
                        // Remove the entire matcher group if no hooks left
                        eventArray.remove(at: groupIdx)
                    } else {
                        var updatedGroup = group
                        updatedGroup["hooks"] = groupHooks
                        eventArray[groupIdx] = updatedGroup
                    }
                }
            }

            if eventArray.isEmpty {
                hooks.removeValue(forKey: event)
            } else {
                hooks[event] = eventArray
            }
        }

        if hooks.isEmpty {
            settings.removeValue(forKey: "hooks")
        } else {
            settings["hooks"] = hooks
        }

        let data = try JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: settingsURL)

        if removedCount > 0 {
            print("Removed \(removedCount) cc-notify hook(s) from ~/.claude/settings.json")
        } else {
            print("No cc-notify hooks found to remove.")
        }
    }
}
