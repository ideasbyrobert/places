import SwiftUI

struct PermissionView: View
{
    @ObservedObject var authorization: AccessibilityAuthorizationService
    let close: @MainActor () -> Void

    var body: some View
    {
        VStack(alignment: .leading, spacing: 20)
        {
            Image(systemName: authorization.isTrusted ? "checkmark.shield.fill" : "rectangle.3.group")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(authorization.isTrusted ? Color.green : Color.accentColor)

            VStack(alignment: .leading, spacing: 8)
            {
                Text(authorization.isTrusted ? "Ready to Arrange Windows" : "Allow Window Arrangement")
                    .font(.title2.weight(.semibold))
                Text(
                    authorization.isTrusted
                        ? "GridWindowManager can now move the focused window."
                        : "macOS requires Accessibility permission before an app can move or resize another app’s window. GridWindowManager does not read window titles, documents, general typing, or screen contents."
                )
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            HStack
            {
                if authorization.isTrusted
                {
                    Spacer()
                    Button("Done", action: close)
                        .keyboardShortcut(.defaultAction)
                }
                else
                {
                    Button("Not Now", action: close)
                    Spacer()
                    Button("Open System Settings")
                    {
                        authorization.openSystemSettings()
                    }
                    Button("Allow Accessibility")
                    {
                        authorization.requestAuthorization()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(28)
        .frame(width: 500)
        .onChange(of: authorization.isTrusted)
        {
            _, trusted in
            if trusted
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
                {
                    close()
                }
            }
        }
    }
}
