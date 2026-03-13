import ArgumentParser

@main
struct CCNotify: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cc-notify",
        abstract: "Clippy-style Clawd notifications for Claude Code",
        version: "1.0.0",
        subcommands: [ShowCommand.self, InstallCommand.self, UninstallCommand.self],
        defaultSubcommand: ShowCommand.self
    )
}
