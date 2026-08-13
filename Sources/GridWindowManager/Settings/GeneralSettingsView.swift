import SwiftUI

struct GeneralSettingsView: View
{
    @ObservedObject var controller: AppController
    @ObservedObject var preferences: AppPreferences
    @ObservedObject var authorization: AccessibilityAuthorizationService
    @ObservedObject var launchAtLogin: LaunchAtLoginService

    init(controller: AppController)
    {
        self.controller = controller
        preferences = controller.preferences
        authorization = controller.authorization
        launchAtLogin = controller.launchAtLogin
    }

    var body: some View
    {
        Form
        {
            Section("Layouts")
            {
                Picker("Default grid", selection: $preferences.gridDimension)
                {
                    ForEach(GridDimension.allCases, id: \.self)
                    {
                        dimension in
                        Text(dimension.title)
                            .tag(dimension)
                    }
                }
                .pickerStyle(.segmented)

                HStack
                {
                    Slider(value: $preferences.spacing, in: 0...32, step: 1)
                    Text("\(Int(preferences.spacing)) pt")
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Window spacing")

                Toggle("Show placement preview", isOn: $preferences.showsPreview)

                Toggle("Snap windows at screen edges", isOn: $preferences.edgeSnappingEnabled)

                HStack
                {
                    Slider(value: $preferences.adjustmentStep, in: 8...128, step: 8)
                    Text("\(Int(preferences.adjustmentStep)) pt")
                        .monospacedDigit()
                        .frame(width: 48, alignment: .trailing)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Move and resize step")
            }

            Section("Keyboard")
            {
                LabeledContent("Open layout palette")
                {
                    ShortcutRecorderView(
                        shortcut: preferences.paletteShortcut,
                        errorMessage: controller.shortcutErrorMessage,
                        onShortcut: controller.updatePaletteShortcut
                    )
                }
            }

            Section("System")
            {
                Toggle("Launch at login", isOn: launchAtLoginBinding)

                LabeledContent("Accessibility")
                {
                    HStack
                    {
                        Text(authorization.isTrusted ? "Allowed" : "Required")
                            .foregroundStyle(
                                authorization.isTrusted ? Color.secondary : Color.red
                            )
                        Button(authorization.isTrusted ? "Open Settings" : "Allow")
                        {
                            if authorization.isTrusted
                            {
                                authorization.openSystemSettings()
                            }
                            else
                            {
                                controller.showPermissionWindow()
                            }
                        }
                    }
                }

                if let errorMessage = launchAtLogin.errorMessage
                {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
    }

    private var launchAtLoginBinding: Binding<Bool>
    {
        Binding(
            get:
            {
                launchAtLogin.isEnabled
            },
            set:
            {
                launchAtLogin.setEnabled($0)
            }
        )
    }
}
