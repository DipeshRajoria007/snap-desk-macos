import AppKit
import ApplicationServices

enum AccessibilityHelper {

    /// Returns true if the app has Accessibility permission
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Prompts user to grant Accessibility permission if not already granted
    static func requestAccessIfNeeded() {
        guard !isTrusted else { return }

        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    /// Shows an alert directing the user to System Settings
    static func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "SnapDesk needs Accessibility access to manage window positions.\n\nGo to System Settings > Privacy & Security > Accessibility and enable SnapDesk."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }

    private static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
