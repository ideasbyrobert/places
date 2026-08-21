import SwiftUI

@main
struct PlacesApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var controller = AppController.shared

    var body: some Scene
    {
        MenuBarExtra("Places", systemImage: "square.grid.3x3")
        {
            MenuBarContent(controller: controller)
        }
        .menuBarExtraStyle(.menu)

        Settings
        {
            SettingsView(controller: controller)
        }
        .restorationBehavior(.disabled)
    }
}
