import Foundation

final class ProfileManager: ObservableObject {

    static let shared = ProfileManager()

    @Published var profiles: [Profile] = []

    private let storageURL: URL

    private init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let snapDeskDir = homeDir.appendingPathComponent(".snapdesk")
        self.storageURL = snapDeskDir.appendingPathComponent("profiles.json")

        // Create directory if needed
        try? FileManager.default.createDirectory(at: snapDeskDir, withIntermediateDirectories: true)

        loadProfiles()
    }

    // MARK: - CRUD

    func saveCurrentLayout(name: String) {
        let screens = ScreenManager.shared.getCurrentScreens()
        let windows = WindowManager.shared.captureAllWindows(screens: screens)
        let profile = Profile(name: name, screens: screens, windows: windows)
        profiles.append(profile)
        persistProfiles()
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        persistProfiles()
    }

    func renameProfile(_ profile: Profile, to newName: String) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].name = newName
        persistProfiles()
    }

    func restoreProfile(_ profile: Profile) {
        WindowManager.shared.restoreWindows(from: profile)
    }

    // MARK: - Persistence

    private func loadProfiles() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            profiles = try decoder.decode([Profile].self, from: data)
        } catch {
            print("Failed to load profiles: \(error)")
        }
    }

    private func persistProfiles() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profiles)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("Failed to save profiles: \(error)")
        }
    }
}
