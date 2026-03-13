import AppKit

final class ClawdView: NSView {
    var expression: ClawdExpression = .happy {
        didSet { needsDisplay = true }
    }

    /// Animation phase, drives the idle bob
    var phase: CGFloat = 0.0 {
        didSet { needsDisplay = true }
    }

    // Official Clawd color: RGB(215, 119, 87) = #D77757
    // Palette built around the official color
    private let palette: [Int: NSColor] = [
        0: .clear,
        1: NSColor(red: 0.843, green: 0.467, blue: 0.341, alpha: 1.0),  // #D77757 official Clawd body
        2: NSColor(red: 0.667, green: 0.333, blue: 0.231, alpha: 1.0),  // #AA553B dark outline
        3: NSColor(red: 0.933, green: 0.600, blue: 0.467, alpha: 1.0),  // #EE9977 light highlight
        4: NSColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0),  // white (eyes)
        5: NSColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1.0),  // #222 dark (pupils/mouth)
        6: NSColor(red: 0.910, green: 0.514, blue: 0.400, alpha: 1.0),  // #E88366 claw
        7: NSColor(red: 0.580, green: 0.267, blue: 0.180, alpha: 1.0),  // #94442E deep shadow
        8: NSColor(red: 0.960, green: 0.690, blue: 0.580, alpha: 1.0),  // #F5B094 belly/cheek highlight
    ]

    //  Clawd pixel art — a cute retro crab inspired by the official mascot
    //  26 columns x 22 rows
    //  0=clear 1=body 2=outline 3=highlight 4=white 5=dark 6=claw 7=deep 8=belly
    private let happyGrid: [[Int]] = [
        // Eye stalks
        [ 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0 ],
        [ 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 2, 0, 0, 0, 0, 2, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0 ],
        // Eyes
        [ 0, 0, 0, 0, 0, 0, 0, 2, 4, 4, 2, 0, 0, 0, 0, 2, 4, 4, 2, 0, 0, 0, 0, 0, 0, 0 ],
        [ 0, 0, 0, 0, 0, 0, 0, 2, 4, 5, 2, 0, 0, 0, 0, 2, 5, 4, 2, 0, 0, 0, 0, 0, 0, 0 ],
        [ 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0 ],
        // Shell top
        [ 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0 ],
        [ 0, 0, 0, 0, 0, 2, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 2, 0, 0, 0, 0, 0 ],
        // Claws + shell body
        [ 0, 0, 6, 6, 2, 2, 1, 1, 3, 3, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 2, 2, 6, 6, 0, 0 ],
        [ 0, 6, 6, 7, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 7, 6, 6, 0 ],
        [ 6, 6, 7, 0, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0, 7, 6, 6 ],
        [ 6, 7, 0, 0, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0, 0, 7, 6 ],
        [ 0, 0, 0, 0, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0, 0, 0, 0 ],
        // Belly + face
        [ 0, 0, 0, 0, 2, 1, 8, 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 8, 8, 1, 2, 0, 0, 0, 0 ],
        [ 0, 0, 0, 0, 2, 1, 8, 8, 1, 1, 5, 0, 0, 0, 5, 1, 1, 1, 8, 8, 1, 2, 0, 0, 0, 0 ],
        [ 0, 0, 0, 0, 2, 1, 1, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 1, 1, 2, 0, 0, 0, 0 ],
        // Shell bottom
        [ 0, 0, 0, 0, 0, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 2, 2, 2, 0, 0, 0, 0, 0 ],
        // Legs
        [ 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0 ],
        [ 0, 0, 0, 2, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 2, 2, 0, 0, 2, 0, 2, 0, 0, 0, 0 ],
        [ 0, 0, 2, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 2, 0, 0, 0 ],
    ]

    private var alertGrid: [[Int]] {
        var grid = happyGrid
        // Open mouth (row 13) — wider surprised expression
        grid[13] = [ 0, 0, 0, 0, 2, 1, 8, 8, 1, 5, 5, 5, 5, 5, 5, 5, 1, 1, 8, 8, 1, 2, 0, 0, 0, 0 ]
        // Mouth interior (row 14)
        grid[14] = [ 0, 0, 0, 0, 2, 1, 1, 8, 8, 5, 7, 7, 7, 7, 7, 5, 8, 8, 8, 1, 1, 2, 0, 0, 0, 0 ]
        return grid
    }

    private var currentGrid: [[Int]] {
        switch expression {
        case .happy: return happyGrid
        case .alert: return alertGrid
        }
    }

    private let pixelSize: CGFloat = 5.0

    override var intrinsicContentSize: NSSize {
        let cols = happyGrid[0].count
        let rows = happyGrid.count
        return NSSize(width: CGFloat(cols) * pixelSize, height: CGFloat(rows) * pixelSize)
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let grid = currentGrid
        let bobOffset = sin(phase * .pi * 2) * 1.5

        for (row, rowData) in grid.enumerated() {
            for (col, colorIndex) in rowData.enumerated() {
                guard colorIndex != 0 else { continue }
                guard let color = palette[colorIndex] else { continue }

                let x = CGFloat(col) * pixelSize
                let y = CGFloat(row) * pixelSize + bobOffset

                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: pixelSize, height: pixelSize))
            }
        }
    }
}
