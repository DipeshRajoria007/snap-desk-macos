import AppKit
import CoreGraphics

final class ScreenManager {

    static let shared = ScreenManager()
    private init() {}

    /// Returns info for all currently connected screens
    func getCurrentScreens() -> [ScreenInfo] {
        NSScreen.screens.compactMap { screen in
            guard let displayID = screenID(for: screen) else { return nil }
            let name = screen.localizedName
            return ScreenInfo(displayID: displayID, localizedName: name, frame: screen.frame)
        }
    }

    /// Generates a stable unique ID for a display using vendor + model + serial
    func screenID(for screen: NSScreen) -> String? {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        guard let screenNumber = screen.deviceDescription[key] as? CGDirectDisplayID else {
            return nil
        }
        let vendor = CGDisplayVendorNumber(screenNumber)
        let model = CGDisplayModelNumber(screenNumber)
        let serial = CGDisplaySerialNumber(screenNumber)

        // If serial is 0 (common for built-in displays), include the display unit number
        if serial == 0 {
            let unit = CGDisplayUnitNumber(screenNumber)
            return "\(vendor)-\(model)-unit\(unit)"
        }
        return "\(vendor)-\(model)-\(serial)"
    }

    /// Match a saved screen ID to a currently connected screen
    func findCurrentScreen(for savedScreenID: String) -> NSScreen? {
        for screen in NSScreen.screens {
            if screenID(for: screen) == savedScreenID {
                return screen
            }
        }
        return nil
    }

    /// Compute the offset between a saved screen position and its current position
    /// This handles when the same screen is reconnected in a different arrangement
    func screenOffset(savedScreen: ScreenInfo, currentScreen: NSScreen) -> CGPoint {
        let dx = currentScreen.frame.origin.x - savedScreen.originX
        let dy = currentScreen.frame.origin.y - savedScreen.originY
        return CGPoint(x: dx, y: dy)
    }
}
