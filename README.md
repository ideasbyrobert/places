# GridWindowManager

GridWindowManager is a native macOS menu-bar utility for arranging individual windows and complete app window sets. It adds contiguous 3×3, 4×4, and 4×2 grid spans to familiar halves and quarters, thirds and two-thirds, centered sizes, edge snapping, incremental movement and resizing, window actions, undo, and saved per-app layouts.

The app uses the macOS Accessibility API only to identify standard windows and perform the requested window operation. It does not read window titles, document contents, general typing, or screen pixels, and it has no network feature. Saved layouts contain only the app bundle identifier and normalized window frames. When edge snapping is enabled, the app observes left-button down, drag, and release events long enough to confirm that the window under the initial pointer moved; it does not record those events. The global shortcut service receives only the shortcut combination the user configures.

## Requirements

- macOS 15 or later
- Xcode with Swift 6 support
- XcodeGen

Install XcodeGen with Homebrew if needed:

```sh
brew install xcodegen
```

## Build and run

```sh
./script/build_and_run.sh
```

The script generates `GridWindowManager.xcodeproj`, builds into `.build/DerivedData`, stops an older development instance, and launches the new app. The generated Xcode project is intentionally not committed.

The Codex Run button uses the same script through `.codex/environments/environment.toml`.

Additional development modes are available:

```sh
./script/build_and_run.sh --debug
./script/build_and_run.sh --logs
./script/build_and_run.sh --telemetry
./script/build_and_run.sh --verify
```

## First launch

GridWindowManager explains why Accessibility permission is required before asking macOS to grant it. Choose Allow Accessibility, enable GridWindowManager in Privacy & Security > Accessibility, then return to the app. No Screen Recording or Input Monitoring permission is requested.

## Use

The default global shortcut is Control-Option-Command-G. It can be replaced in Settings.

In the palette:

- Click a common layout to apply it.
- Use the Thirds, Center, Move, and Resize menus for the extended command set.
- Click a grid cell to use a one-cell region.
- Drag from any cell to any other cell to select the contiguous rectangular span between them.
- Press 2 for the 4×2 grid, 3 for the 3×3 grid, or 4 for the 4×4 grid.
- Use arrow keys to move the current region.
- Use Shift-arrow to extend the region.
- Use Option-arrow to move the window by the configured step.
- Use Command-arrow to resize the window by the configured step.
- Press F to fill, C to center, W to maximize width, or H to maximize height.
- Press Return to apply or Escape to cancel.

The menu-bar action Arrange App Windows 4 × 2 places every manageable standard window from the previously frontmost application into the grid in row-major order. It is available for one through eight windows and unavailable when the application has nine or more windows, no manageable windows, a minimized window, or a full-screen window.

Dragging a standard window to the left or right edge snaps it to a half. Top and bottom corners snap to quarters, the top center fills the usable screen, and the bottom center uses the bottom half. The app verifies that the window itself moved before showing or applying a snap target, so a drag inside window content does not trigger placement. Restore Previous Frame returns a snapped window to its pre-drag frame.

Saved App Layouts provides three slots per application. Saving captures the ordered standard-window frames on the focused window’s current display. Restoring requires the same number of manageable app windows on that display, then scales the stored geometry to its current usable frame. No window title is used for matching.

The menu also includes horizontal and vertical thirds, two-thirds, centered fractions, move-to-edge and move-to-corner commands, configurable-step movement and resizing, previous and next app-window focus, minimize, zoom, full screen, close, and restore. Settings control window spacing, placement preview, edge snapping, move and resize step, the palette shortcut, and launch at login.

For Terminal windows, character dimensions such as 80 columns by 48 rows remain part of the Terminal profile. GridWindowManager controls the window's screen region and does not change application-specific document or terminal settings.

## Tests

Run the deterministic geometry, model, display, and UI suites with:

```sh
./script/test.sh
```

The Accessibility integration test is intentionally skipped during the normal suite because it moves real windows. To run it explicitly:

```sh
./script/test.sh --live-accessibility
```

Grant the development test runner Accessibility permission first. The live test launches the included fixture app and exercises standard-window capture, pointer hit-testing, 4×2 batch movement, centered placement, incremental movement, undo, and window raising. The fixture app also provides resizable, minimum-size, fixed-size, and dialog windows for manual acceptance checks.

The end-to-end app test requires Accessibility permission for the built GridWindowManager app rather than the test runner:

```sh
./script/test.sh --live-app-accessibility
```

It opens the real menu-bar command against the fixture app, verifies that the fixture window moves into the 4×2 layout, and verifies Restore Previous Frame returns its original geometry.

## Direct distribution

The release script archives a universal arm64 and x86_64 app, signs it with Developer ID, creates a signed disk image, submits it for notarization, staples the ticket, and runs Gatekeeper checks.

```sh
DEVELOPER_ID_APPLICATION='Developer ID Application: Your Name (TEAMID)' \
DEVELOPMENT_TEAM='TEAMID' \
NOTARYTOOL_PROFILE='GridWindowManager-Notary' \
./script/package_release.sh
```

Create the notary profile once with `xcrun notarytool store-credentials`. Successful output is written to `dist/GridWindowManager.dmg`.

## Scope boundaries

GridWindowManager manages standard Accessibility windows. It does not rearrange tabs, invoke app-specific tiling semantics, automate Stage Manager, or use private window-server APIs. Saved layouts intentionally stay within the focused display and match windows by stable Accessibility order rather than titles. Display routing remains limited to the existing previous and next display commands while broader display management is deferred. Fixed-size or constrained windows receive the closest reachable placement the owning app permits.
