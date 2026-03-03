import SwiftUI

@main
struct SnapDeskApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("SnapDesk", systemImage: "rectangle.3.group") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request accessibility permission on first launch
        AccessibilityHelper.requestAccessIfNeeded()
    }
}
