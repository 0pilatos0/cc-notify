import ArgumentParser
import Foundation

struct ShowCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Display a Clawd notification overlay"
    )

    @Option(name: .long, help: "Event type: stop or notification")
    var event: String = "stop"

    @Option(name: .long, help: "Custom message to display")
    var message: String?

    mutating func run() throws {
        // Try to read hook JSON from stdin (non-blocking)
        let hookEvent = Self.readStdinJSON()

        // Determine style from --event flag or hook event name
        let eventName = hookEvent?.hookEventName ?? event
        let style = NotificationStyle.from(eventString: eventName)

        // Determine message: CLI flag > hook JSON > random default
        let displayMessage = message
            ?? hookEvent?.message
            ?? style.defaultMessages.randomElement()!

        // Launch the overlay
        NotifyApp.launch(style: style, message: displayMessage)
    }

    private static func readStdinJSON() -> HookEvent? {
        // Only read if stdin is a pipe (not a terminal)
        guard isatty(STDIN_FILENO) == 0 else { return nil }

        let data = FileHandle.standardInput.availableData
        guard !data.isEmpty else { return nil }

        return try? JSONDecoder().decode(HookEvent.self, from: data)
    }
}
