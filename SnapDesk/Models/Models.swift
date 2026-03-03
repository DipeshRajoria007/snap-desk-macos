import Foundation
import CoreGraphics

// MARK: - Screen Info

struct ScreenInfo: Codable, Hashable {
    let displayID: String
    let localizedName: String
    let originX: Double
    let originY: Double
    let width: Double
    let height: Double

    var frame: CGRect {
        CGRect(x: originX, y: originY, width: width, height: height)
    }

    init(displayID: String, localizedName: String, frame: CGRect) {
        self.displayID = displayID
        self.localizedName = localizedName
        self.originX = frame.origin.x
        self.originY = frame.origin.y
        self.width = frame.size.width
        self.height = frame.size.height
    }
}

// MARK: - Window Snapshot

struct WindowSnapshot: Codable {
    let appBundleID: String
    let appName: String
    let windowTitle: String
    let originX: Double
    let originY: Double
    let width: Double
    let height: Double
    let screenID: String

    var frame: CGRect {
        CGRect(x: originX, y: originY, width: width, height: height)
    }

    init(appBundleID: String, appName: String, windowTitle: String, frame: CGRect, screenID: String) {
        self.appBundleID = appBundleID
        self.appName = appName
        self.windowTitle = windowTitle
        self.originX = frame.origin.x
        self.originY = frame.origin.y
        self.width = frame.size.width
        self.height = frame.size.height
        self.screenID = screenID
    }
}

// MARK: - Profile

struct Profile: Codable, Identifiable {
    let id: UUID
    var name: String
    let createdAt: Date
    var screens: [ScreenInfo]
    var windows: [WindowSnapshot]

    init(name: String, screens: [ScreenInfo], windows: [WindowSnapshot]) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.screens = screens
        self.windows = windows
    }
}
