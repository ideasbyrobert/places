import SwiftUI

struct FixtureControlView: View
{
    @Environment(\.openWindow) private var openWindow
    @State private var showsDialog = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 18)
        {
            Text("Window Movement Fixtures")
                .font(.title2.weight(.semibold))
            Text("Open a fixture, focus it, then exercise GridWindowManager’s live Accessibility path.")
                .foregroundStyle(.secondary)

            Button("Open Resizable Window")
            {
                openWindow(id: "resizable")
            }

            Button("Open Minimum Size Window")
            {
                openWindow(id: "minimum")
            }

            Button("Open Fixed Size Window")
            {
                openWindow(id: "fixed")
            }

            Button("Show Dialog")
            {
                showsDialog = true
            }

            Spacer()
        }
        .padding(28)
        .alert("System Dialog Fixture", isPresented: $showsDialog)
        {
            Button("Dismiss", role: .cancel)
            {
            }
        }
    }
}
