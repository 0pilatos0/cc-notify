import ArgumentParser
import Foundation

struct InstallCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Configure Claude Code hooks for cc-notify"
    )

    @Option(name: .long, help: "Path to the cc-notify binary (auto-detected if omitted)")
    var binaryPath: String?

    mutating func run() throws {
        let binPath = binaryPath ?? Self.resolveBinaryPath()
        let settingsURL = Self.settingsURL()

        // Ensure ~/.claude directory exists
        let claudeDir = settingsURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: claudeDir, withIntermediateDirectories: true)

        // Read existing settings or start fresh
        var settings = Self.readSettings(from: settingsURL)

        // Get or create hooks dict
        var hooks = settings["hooks"] as? [String: Any] ?? [:]

        // Add Stop hook
        hooks = Self.mergeHook(
            into: hooks,
            event: "Stop",
            command: "\(binPath) show --event stop"
        )

        // Add Notification hook
        hooks = Self.mergeHook(
            into: hooks,
            event: "Notification",
            command: "\(binPath) show --event notification"
        )

        settings["hooks"] = hooks

        // Write back
        let data = try JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: settingsURL)

        print("Installed cc-notify hooks in ~/.claude/settings.json")
        print("  Stop → \(binPath) show --event stop")
        print("  Notification → \(binPath) show --event notification")
        print("")
        print("Run 'cc-notify show --event stop' to test it!")
    }

    private static func resolveBinaryPath() -> String {
        // Use the current executable path
        let execPath = ProcessInfo.processInfo.arguments[0]
        // Resolve symlinks
        let resolved = (execPath as NSString).resolvingSymlinksInPath
        return resolved
    }

    static func settingsURL() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
            .appendingPathComponent("settings.json")
    }

    static func readSettings(from url: URL) -> [String: Any] {
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return [:]
        }
        return json
    }

    static func mergeHook(into hooks: [String: Any], event: String, command: String) -> [String: Any] {
        var hooks = hooks
        var eventArray = hooks[event] as? [[String: Any]] ?? []

        let newHookEntry: [String: Any] = [
            "type": "command",
            "command": command,
            "timeout": 10,
        ]

        let newMatcherGroup: [String: Any] = [
            "matcher": "",
            "hooks": [newHookEntry],
        ]

        // Check if there's already a cc-notify hook in any matcher group
        var found = false
        for (groupIdx, group) in eventArray.enumerated() {
            if var groupHooks = group["hooks"] as? [[String: Any]] {
                for (hookIdx, hook) in groupHooks.enumerated() {
                    if let cmd = hook["command"] as? String, cmd.contains("cc-notify") {
                        // Replace existing cc-notify entry
                        groupHooks[hookIdx] = newHookEntry
                        var updatedGroup = group
                        updatedGroup["hooks"] = groupHooks
                        eventArray[groupIdx] = updatedGroup
                        found = true
                        break
                    }
                }
                if found { break }
            }
        }

        if !found {
            eventArray.append(newMatcherGroup)
        }

        hooks[event] = eventArray
        return hooks
    }
}
