import AppKit
import ApplicationServices
import Combine
import Foundation

@MainActor
final class AccessibilityAuthorizationService: ObservableObject
{
    @Published private(set) var isTrusted = AXIsProcessTrusted()

    private var timer: Timer?

    func refresh()
    {
        isTrusted = AXIsProcessTrusted()
        if isTrusted
        {
            timer?.invalidate()
            timer = nil
        }
    }

    func requestAuthorization()
    {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        isTrusted = AXIsProcessTrustedWithOptions(options)
        beginPolling()
    }

    func openSystemSettings()
    {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        )
        else
        {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func beginPolling()
    {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
        {
            [weak self] _ in
            Task
            {
                @MainActor in
                self?.refresh()
            }
        }
    }
}
