import SwiftUI

struct MenuBarContent: View
{
    @ObservedObject var controller: AppController
    @ObservedObject private var preferences: AppPreferences
    @ObservedObject private var authorization: AccessibilityAuthorizationService
    @ObservedObject private var desktopVisibility: DesktopVisibilityService
    @ObservedObject private var updates: UpdateController

    init(controller: AppController)
    {
        self.controller = controller
        preferences = controller.preferences
        authorization = controller.authorization
        desktopVisibility = controller.desktopVisibility
        updates = controller.updates
    }

    var body: some View
    {
        Button("Open Layout Palette")
        {
            controller.openPalette()
        }

        Button("Arrange App Windows 3 × 2")
        {
            controller.arrangeAllWindowsThreeByTwo()
        }
        .disabled(!controller.batchArrangementAvailability.isAvailable)

        Button("Arrange App Windows 4 × 2")
        {
            controller.arrangeAllWindowsFourByTwo()
        }
        .disabled(!controller.batchArrangementAvailability.isAvailable)
        .onAppear
        {
            controller.refreshBatchArrangementAvailability()
        }

        Text(controller.batchArrangementAvailability.detailText)

        Text("Shortcut: \(preferences.paletteShortcut.displayName)")

        Menu("Pro Splits")
        {
            ForEach(LayoutPreset.masterStackCases, id: \.self)
            {
                preset in
                Button(preset.title)
                {
                    controller.applyPreset(preset)
                }
            }
        }

        Menu("Thirds")
        {
            ForEach(LayoutPreset.horizontalThirdCases, id: \.self)
            {
                preset in
                Button(preset.title)
                {
                    controller.applyPreset(preset)
                }
            }

            Divider()

            ForEach(LayoutPreset.verticalThirdCases, id: \.self)
            {
                preset in
                Button(preset.title)
                {
                    controller.applyPreset(preset)
                }
            }
        }

        Menu("Triptych & Center Focus")
        {
            ForEach(LayoutPreset.triptychCases, id: \.self)
            {
                preset in
                Button(preset.title)
                {
                    controller.applyPreset(preset)
                }
            }

            Divider()

            ForEach(LayoutPreset.centeredSizeCases, id: \.self)
            {
                preset in
                Button(preset.title)
                {
                    controller.applyPreset(preset)
                }
            }
        }

        Menu("Common Layouts")
        {
            ForEach(LayoutPreset.paletteCases, id: \.self)
            {
                preset in
                Button(preset.title)
                {
                    controller.applyPreset(preset)
                }
            }
        }

        Menu("Size and Position")
        {
            Button(LayoutPreset.maximizeWidth.title)
            {
                controller.applyPreset(.maximizeWidth)
            }

            Button(LayoutPreset.maximizeHeight.title)
            {
                controller.applyPreset(.maximizeHeight)
            }

            Divider()

            ForEach(WindowMovePosition.allCases, id: \.self)
            {
                position in
                Button(position.title)
                {
                    controller.moveWindow(position)
                }
            }
        }

        Menu("Move and Resize")
        {
            ForEach(WindowAdjustment.allCases, id: \.self)
            {
                adjustment in
                Button(adjustment.title)
                {
                    controller.applyAdjustment(adjustment)
                }
            }
        }

        Menu("Saved App Layouts")
        {
            ForEach(1...3, id: \.self)
            {
                slot in
                Menu("Slot \(slot)")
                {
                    Button("Restore")
                    {
                        controller.restoreAppLayout(slot: slot)
                    }
                    .disabled(!controller.savedLayoutSlots.contains(slot))

                    Button("Save Current Arrangement")
                    {
                        controller.saveAppLayout(slot: slot)
                    }

                    if controller.savedLayoutSlots.contains(slot)
                    {
                        Divider()

                        Button("Delete", role: .destructive)
                        {
                            controller.deleteAppLayout(slot: slot)
                        }
                    }
                }
            }
        }
        .onAppear
        {
            controller.refreshSavedLayoutSlots()
        }

        Menu("Desktop")
        {
            Button(desktopVisibility.isDesktopShown ? "Restore Desktop" : "Show Desktop")
            {
                controller.showOrRestoreDesktop()
            }
        }

        Menu("Displays")
        {
            Button("Swap Windows Between Displays")
            {
                controller.swapWindowsBetweenDisplays()
            }

            Divider()

            Button("Gather App Windows on This Display")
            {
                controller.gatherAppWindowsOnFocusedDisplay()
            }

            Button("Move App Windows to Previous Display")
            {
                controller.moveAppWindowsToPreviousDisplay()
            }

            Button("Move App Windows to Next Display")
            {
                controller.moveAppWindowsToNextDisplay()
            }

            Divider()

            Button("Move Focused Window to Previous Display")
            {
                controller.moveToPreviousDisplay()
            }

            Button("Move Focused Window to Next Display")
            {
                controller.moveToNextDisplay()
            }
        }

        Divider()

        Button("Restore Previous Frame")
        {
            controller.restorePreviousFrame()
        }

        Menu("Window Actions")
        {
            ForEach(WindowFocusDirection.allCases, id: \.self)
            {
                direction in
                Button(direction.title)
                {
                    controller.focusAppWindow(direction)
                }
            }

            Divider()

            ForEach(WindowLifecycleAction.menuCases, id: \.self)
            {
                action in
                Button(action.title)
                {
                    controller.performWindowAction(action)
                }
            }
        }

        if let statusMessage = controller.statusMessage
        {
            Divider()
            Text(statusMessage)
        }

        Divider()

        Button(authorization.isTrusted ? "Window Control: Allowed" : "Window Control: Required")
        {
            controller.showPermissionWindow()
        }

        SettingsLink
        {
            Text("Settings…")
        }

        Button("About GridWindowManager")
        {
            controller.showAbout()
        }

        Button("Check for Updates…")
        {
            controller.updates.checkForUpdates()
        }
        .disabled(!updates.canCheck)

        Divider()

        Button("Quit GridWindowManager")
        {
            controller.quit()
        }
    }
}
