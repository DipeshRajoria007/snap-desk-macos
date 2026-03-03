import AppKit
import CoreGraphics
import ApplicationServices

final class WindowManager {

    static let shared = WindowManager()
    private init() {}

    // MARK: - Capture

    /// Captures all standard app windows currently on screen
    func captureAllWindows(screens: [ScreenInfo]) -> [WindowSnapshot] {
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return []
        }

        var snapshots: [WindowSnapshot] = []

        for windowInfo in windowList {
            guard let pid = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
                  let ownerName = windowInfo[kCGWindowOwnerName as String] as? String,
                  let layer = windowInfo[kCGWindowLayer as String] as? Int,
                  layer == 0, // standard windows only (layer 0)
                  let boundsDict = windowInfo[kCGWindowBounds as String] as? [String: CGFloat]
            else { continue }

            // Skip system processes
            let skipApps = ["WindowManager", "Window Server", "SystemUIServer", "Control Center", "Notification Center"]
            if skipApps.contains(ownerName) { continue }

            let x = boundsDict["X"] ?? 0
            let y = boundsDict["Y"] ?? 0
            let w = boundsDict["Width"] ?? 0
            let h = boundsDict["Height"] ?? 0
            let frame = CGRect(x: x, y: y, width: w, height: h)

            // Skip tiny windows (likely hidden/system elements)
            if w < 50 || h < 50 { continue }

            let app = NSRunningApplication(processIdentifier: pid)
            let bundleID = app?.bundleIdentifier ?? ownerName
            let windowTitle = windowInfo[kCGWindowName as String] as? String ?? ""

            // Determine which screen this window is on
            let screenID = screenIDForWindow(frame: frame, screens: screens)

            let snapshot = WindowSnapshot(
                appBundleID: bundleID,
                appName: ownerName,
                windowTitle: windowTitle,
                frame: frame,
                screenID: screenID
            )
            snapshots.append(snapshot)
        }

        return snapshots
    }

    // MARK: - Restore

    /// Restores windows to their saved positions
    func restoreWindows(from profile: Profile) {
        let screenManager = ScreenManager.shared
        // Build a map of saved screenID -> offset
        var screenOffsets: [String: CGPoint] = [:]
        var availableScreenIDs: Set<String> = []

        for savedScreen in profile.screens {
            if let currentScreen = screenManager.findCurrentScreen(for: savedScreen.displayID) {
                let offset = screenManager.screenOffset(savedScreen: savedScreen, currentScreen: currentScreen)
                screenOffsets[savedScreen.displayID] = offset
                availableScreenIDs.insert(savedScreen.displayID)
            }
        }

        // Group windows by app bundle ID for efficient AX access
        let windowsByApp = Dictionary(grouping: profile.windows) { $0.appBundleID }

        for (bundleID, savedWindows) in windowsByApp {
            // Find running app
            guard let runningApp = NSRunningApplication.runningApplications(
                withBundleIdentifier: bundleID
            ).first else {
                continue // skip silently
            }

            let appElement = AXUIElementCreateApplication(runningApp.processIdentifier)

            var windowsRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)
            guard result == .success, let axWindows = windowsRef as? [AXUIElement] else {
                continue
            }

            for savedWindow in savedWindows {
                // Skip if the screen isn't connected
                guard availableScreenIDs.contains(savedWindow.screenID) else { continue }

                let offset = screenOffsets[savedWindow.screenID] ?? .zero

                // Try to match by window title
                let targetAXWindow = findMatchingWindow(
                    axWindows: axWindows,
                    savedTitle: savedWindow.windowTitle
                ) ?? axWindows.first // fallback to first window

                guard let axWindow = targetAXWindow else { continue }

                // Apply position with screen offset
                var newOrigin = CGPoint(
                    x: savedWindow.originX + offset.x,
                    y: savedWindow.originY + offset.y
                )
                var newSize = CGSize(
                    width: savedWindow.width,
                    height: savedWindow.height
                )

                // Set position first, then size
                if let posValue = AXValueCreate(.cgPoint, &newOrigin) {
                    AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, posValue)
                }
                if let sizeValue = AXValueCreate(.cgSize, &newSize) {
                    AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, sizeValue)
                }
            }
        }
    }

    // MARK: - Private Helpers

    private func screenIDForWindow(frame: CGRect, screens: [ScreenInfo]) -> String {
        var bestMatch = screens.first?.displayID ?? "unknown"
        var bestOverlap: CGFloat = 0

        for screen in screens {
            let intersection = frame.intersection(screen.frame)
            if !intersection.isNull {
                let overlap = intersection.width * intersection.height
                if overlap > bestOverlap {
                    bestOverlap = overlap
                    bestMatch = screen.displayID
                }
            }
        }

        return bestMatch
    }

    private func findMatchingWindow(axWindows: [AXUIElement], savedTitle: String) -> AXUIElement? {
        guard !savedTitle.isEmpty else { return nil }

        for axWindow in axWindows {
            var titleRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(axWindow, kAXTitleAttribute as CFString, &titleRef)
            if result == .success, let title = titleRef as? String, title == savedTitle {
                return axWindow
            }
        }
        return nil
    }
}
