# Agent context

This workspace contains a Qt Quick prototype for a floating desktop dock. The standalone preview is the local design and interaction test bed. The intended Linux deployment is a Quickshell panel on Wayland. The app entries are mocks and activation emits `launched` and logs the app name.

## Design language

- Use dark, translucent glass with enough backdrop blur to turn fine detail into soft color. A thin, low contrast light border defines the glass edge. Two soft shadows give the dock some separation from the background.
- Float the dock at the bottom center with a 16 px gap in the preview. The glass plate is 76 px tall by default, with 22 px corner radii. On hover, the plate changes width while icons can grow above it. Keep the icons and running indicators aligned at the bottom.
- Use colorful, borderless tiles with rounded corners and simple white glyphs. Reserve the white outline for keyboard focus. A 4 px dot below the tile marks a running app.
- Tooltips are fully rounded pills centered above their icons. Use the shared glass treatment and a slightly darker tint for readable text. Fade and lift the tooltip 4 px over 130 ms, and reverse the motion when hover ends.
- Treat magnification as a continuous wave. Icons start at 48 px, the icon nearest the pointer can reach 72 px, and neighbors grow less with distance. The hover easing is 120 ms. Pressing compresses the tile toward 90% with a spring and releasing lets it rebound. Keep press feedback separate from layout and hit testing.

## Implementation notes

- `dock-prototype/Preview.qml` hosts the standalone window and draws a wallpaper with crisp, high contrast lines to make the blur easy to evaluate.
- `dock-prototype/dock/Dock.qml` owns hover geometry, row layout, and the glass plate. Preserve fractional item widths and precise centering. Per-icon rounding previously made the plate flicker during horizontal sweeps, and rounding the center made the hover target shift under a stationary pointer.
- `dock-prototype/dock/DockItem.qml` owns icon rendering, press feedback, keyboard activation, the running indicator, and tooltip behavior.
- `dock-prototype/shared/AppCatalog.qml` defines the mock apps used by the dock and launcher.
- `dock-prototype/shared/GlassSurface.qml` provides the shared tint, border, and masked blur. The preview samples a QML backdrop item, using a 48 px blur radius. Software rendering uses the translucent tint fallback.
- The eventual desktop dock must blur the live scene beneath the glass, including real app windows as they move underneath. The Qt preview samples its own wallpaper. On Wayland, use the target compositor’s backdrop blur for the dock surface and verify that the blur tracks moving windows and follows the rounded glass bounds.

## Run and verify

Run from the workspace root with Qt 6 on `PATH`. The prototype has been verified with Homebrew Qt 6.12.

```sh
cd dock-prototype
find . -name '*.qml' -exec qmllint --max-warnings 0 {} +
qml Preview.qml
```

Sweep the pointer across the row in both directions and pause at the center and edges. Check that the width changes smoothly, the plate keeps its height, and the tooltip follows the active icon. Try a quick click, a held press, and activation with Tab followed by Space or Enter. Verify the blur in a native window with GPU rendering. The wallpaper lines should soften through the glass and stay crisp around it.
