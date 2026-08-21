# Places

Places is a native macOS menu-bar utility for arranging individual windows and complete app window sets. It adds contiguous 3×3, 4×4, and 4×2 grid spans to familiar halves and quarters, thirds and two-thirds, centered sizes, balanced app-window arrangement, edge snapping, incremental movement and resizing, display routing, reversible desktop visibility, window actions, undo, and saved per-app layouts.

The app uses the macOS Accessibility API only to identify standard windows and perform the requested window operation. It does not read window titles, document contents, general typing, or screen pixels, and it has no network feature. For exact Terminal sizing, it uses Apple Events only to read Terminal window identifiers and the selected tab's column and row counts, then set those counts to 80 by 48. It does not read Terminal text, commands, history, profiles, or tab contents. Saved layouts contain only the app bundle identifier and normalized window frames. When edge snapping is enabled, the app observes left-button down, drag, and release events long enough to confirm that the window under the initial pointer moved; it does not record those events. The global shortcut service receives only the shortcut combination the user configures.

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

The script generates `Places.xcodeproj`, builds into `.build/DerivedData`, stops an older development instance, and launches the new app. The generated Xcode project is intentionally not committed.

Local builds and test runners use the app’s Apple Development identity so Gatekeeper, Automation, and Accessibility can recognize a stable designated requirement across rebuilds. A different team or identity can be supplied with `GRIDWINDOWMANAGER_DEVELOPMENT_TEAM` and `GRIDWINDOWMANAGER_DEVELOPMENT_IDENTITY`.

The Codex Run button uses the same script through `.codex/environments/environment.toml`.

Additional development modes are available:

```sh
./script/build_and_run.sh --debug
./script/build_and_run.sh --logs
./script/build_and_run.sh --telemetry
./script/build_and_run.sh --verify
```

## First launch

Places explains why Window Control permission is required before opening System Settings. In Privacy & Security, choose Device Control and Data Access on newer macOS releases or Accessibility on earlier releases. Enable `Places.app` itself, not an app whose name ends in `Tests-Runner`, then return to Places. No Screen Recording or Input Monitoring permission is requested. Terminal Automation is separate and is requested only when you explicitly arrange Terminal windows or choose Request in Settings.

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

The menu-bar action Arrange App Windows 4 × 2 places every manageable standard window from the previously frontmost application on the focused display. Visual order is preserved from top to bottom and left to right. One through four windows use one centered row. Five windows use centered rows of three and two, six use three and three, seven use four and three, and eight use four and four. Generic app windows use the canonical 4×2 cell size. The action is unavailable when the application has nine or more windows, no manageable windows, a minimized window, or a full-screen window.

Terminal is handled as an exact-size variant of the same command. Every selected Terminal tab is set to 80 columns by 48 rows before placement while its profile, font, text, and other settings remain untouched. If Terminal Automation is denied, the Terminal and Accessibility window sets disagree, or the exact windows cannot fit on the focused display, the entire command fails closed and restores the original dimensions and frames. Restore Previous Frame restores the whole batch, including each Terminal tab's earlier column and row counts.

Dragging a standard window to the left or right edge snaps it to a half. Top and bottom corners snap to quarters, the top center fills the usable screen, and the bottom center uses the bottom half. The app verifies that the window itself moved before showing or applying a snap target, so a drag inside window content does not trigger placement. Restore Previous Frame returns a snapped window to its pre-drag frame.

Saved App Layouts provides three slots per application. Saving captures the ordered standard-window frames on the focused window’s current display. Restoring requires the same number of manageable app windows on that display, then scales the stored geometry to its current usable frame. No window title is used for matching.

The Displays menu can gather every standard window from the target application onto the focused window’s display or move the whole application window set to the previous or next connected display. Relative window geometry is preserved unless a window has a known layout command, in which case that layout is reapplied on the destination. The batch is one undoable transaction, so Restore Previous Frame returns all moved windows together. Focused-window display movement remains available separately.

Show Desktop uses public macOS application hide and unhide operations. It records only the visible regular applications it actually hid, excludes Finder and Places, and restores only that recorded set. A partial hide is reverted immediately, and a partial restore remains retryable. It does not create, reorder, or automate virtual Spaces.

The menu also includes horizontal and vertical thirds, two-thirds, centered fractions, move-to-edge and move-to-corner commands, configurable-step movement and resizing, previous and next app-window focus, minimize, zoom, full screen, close, and restore. Settings control window spacing, placement preview, edge snapping, move and resize step, the palette shortcut, and launch at login.

## Tests

Run the deterministic geometry, model, display, and UI suites with:

```sh
./script/test.sh
```

The Accessibility integration test is intentionally skipped during the normal suite because it moves real windows. To run it explicitly:

```sh
./script/test.sh --live-accessibility
```

Grant `PlacesTests-Runner.app` Window Control permission first. The live test launches the included fixture app and exercises standard-window capture, pointer hit-testing, 4×2 batch movement, centered placement, incremental movement, whole-app display transfer when multiple displays are available, undo, and window raising. The fixture app also provides resizable, minimum-size, fixed-size, and dialog windows for manual acceptance checks.

The end-to-end app test requires Window Control permission for `Places.app` rather than either test runner:

```sh
./script/test.sh --live-app-accessibility
```

It opens the real menu-bar command against the fixture app, verifies that the fixture window moves into the 4×2 layout, and verifies Restore Previous Frame returns its original geometry.

The permission identities are not interchangeable. Normal use and `--live-app-accessibility` require `Places.app`. Direct `--live-accessibility` and `--live-terminal` integration tests require `PlacesTests-Runner.app`. Do not manually add `PlacesUITests-Runner.app`; it is Xcode's UI-test host, not the window manager.

The Terminal integration test is also explicit because it opens and automates real windows:

```sh
./script/test.sh --live-terminal
```

Quit Terminal first, then grant `PlacesTests-Runner.app` Window Control and Terminal Automation permission if macOS asks. The test launches Terminal without restoring saved windows, creates five disposable windows, verifies exact 80×48 dimensions and the balanced three-plus-two arrangement, restores all original dimensions and frames, and terminates only the fresh Terminal instance it created.

## Direct distribution

The release script archives a universal arm64 and x86_64 app, signs it with Developer ID, creates a signed disk image, submits it for notarization, staples the ticket, and runs Gatekeeper checks.

```sh
DEVELOPER_ID_APPLICATION='Developer ID Application: Your Name (TEAMID)' \
DEVELOPMENT_TEAM='TEAMID' \
NOTARYTOOL_PROFILE='Places-Notary' \
./script/package_release.sh
```

Create the notary profile once with `xcrun notarytool store-credentials`. Successful output is written to `dist/Places.dmg`.

## Scope boundaries

Places manages standard Accessibility windows. Apart from setting the selected Terminal tab to the explicit 80×48 dimensions for batch arrangement, it does not rearrange tabs, invoke app-specific tiling semantics, automate Stage Manager, create or reorder virtual Spaces, or use private window-server APIs. Saved layouts intentionally stay within the focused display and match windows by stable Accessibility order rather than titles. Display routing is limited to gathering or moving the target application’s standard windows between connected displays. Fixed-size or constrained windows receive the closest reachable placement the owning app permits.
