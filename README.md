# cc-notify

Clippy-style desktop notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), featuring the Clawd mascot. Get a friendly pop-up whenever Claude finishes a task or needs your attention.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Clawd overlay notifications** — A borderless, click-through overlay appears in the bottom-right corner of your screen with an animated Clawd character and speech bubble
- **Two notification styles** — "Done" (green, happy Clawd) when a task finishes, "Attention" (orange, alert Clawd) when Claude needs input
- **Smooth animations** — Entrance bounce, idle bobbing, and fade-out exit over a 4.4-second cycle
- **Claude Code hook integration** — One-command install into Claude Code's hook system
- **Works everywhere** — Appears above all windows, across all Spaces and full-screen apps

## Installation

### Download the binary

1. Download `cc-notify` from the [latest release](https://github.com/0pilatos0/cc-notify/releases/latest)
2. Make it executable and move it to your PATH:

```bash
chmod +x cc-notify
sudo mv cc-notify /usr/local/bin/
```

### Build from source

Requires **Swift 5.9+** and **macOS 13.0+**.

```bash
git clone https://github.com/0pilatos0/cc-notify.git
cd cc-notify
swift build -c release
sudo cp .build/release/cc-notify /usr/local/bin/
```

## Setup

Register cc-notify as a Claude Code hook:

```bash
cc-notify install
```

This adds hooks for `Stop` and `Notification` events to `~/.claude/settings.json`. To remove them:

```bash
cc-notify uninstall
```

## Usage

Once installed, cc-notify runs automatically via Claude Code hooks. You can also trigger notifications manually:

```bash
# Show a "done" notification
cc-notify show --event stop

# Show an "attention" notification
cc-notify show --event notification

# Custom message
cc-notify show --event stop --message "Build succeeded!"
```

### Commands

| Command     | Description                                      |
|-------------|--------------------------------------------------|
| `show`      | Display a Clawd notification (default command)   |
| `install`   | Register hooks in `~/.claude/settings.json`      |
| `uninstall` | Remove cc-notify hooks from Claude Code settings |

### Show options

| Option      | Description                          | Default  |
|-------------|--------------------------------------|----------|
| `--event`   | Event type: `stop` or `notification` | `stop`   |
| `--message` | Custom message text                  | Random   |

## How it works

cc-notify creates a transparent, borderless macOS overlay window positioned in the bottom-right corner of your screen. The Clawd character is rendered using Unicode art in Menlo-Bold, and the speech bubble uses a dark retro aesthetic with colored accent lines.

When triggered by a Claude Code hook, cc-notify reads the hook event JSON from stdin to determine the notification style and optional message, then displays the animated overlay for ~4.4 seconds before automatically dismissing.

## Requirements

- macOS 13.0 (Ventura) or later
- Claude Code (for hook integration)

## License

[MIT](LICENSE)
