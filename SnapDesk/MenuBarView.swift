import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @State private var showingSaveDialog = false
    @State private var newProfileName = ""
    @State private var showingRenameDialog = false
    @State private var profileToRename: Profile?
    @State private var renameText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Save button
            MenuButton(title: "Save Current Layout...", icon: "plus.square") {
                showingSaveDialog = true
            }

            Divider().padding(.vertical, 4)

            // Profiles list
            if profileManager.profiles.isEmpty {
                Text("No saved profiles")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            } else {
                ForEach(profileManager.profiles) { profile in
                    ProfileRow(profile: profile, onRestore: {
                        profileManager.restoreProfile(profile)
                    }, onRename: {
                        profileToRename = profile
                        renameText = profile.name
                        showingRenameDialog = true
                    }, onDelete: {
                        profileManager.deleteProfile(profile)
                    })
                }
            }

            Divider().padding(.vertical, 4)

            // Accessibility status
            if !AccessibilityHelper.isTrusted {
                MenuButton(title: "Grant Accessibility Access", icon: "lock.shield") {
                    AccessibilityHelper.showAccessibilityAlert()
                }
                Divider().padding(.vertical, 4)
            }

            // Quit
            MenuButton(title: "Quit SnapDesk", icon: "power") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 8)
        .frame(width: 260)
        .sheet(isPresented: $showingSaveDialog) {
            SaveProfileSheet(
                profileName: $newProfileName,
                onSave: {
                    let name = newProfileName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty {
                        profileManager.saveCurrentLayout(name: name)
                    }
                    newProfileName = ""
                    showingSaveDialog = false
                },
                onCancel: {
                    newProfileName = ""
                    showingSaveDialog = false
                }
            )
        }
        .sheet(isPresented: $showingRenameDialog) {
            RenameProfileSheet(
                profileName: $renameText,
                onSave: {
                    if let profile = profileToRename {
                        let name = renameText.trimmingCharacters(in: .whitespaces)
                        if !name.isEmpty {
                            profileManager.renameProfile(profile, to: name)
                        }
                    }
                    showingRenameDialog = false
                },
                onCancel: {
                    showingRenameDialog = false
                }
            )
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let profile: Profile
    let onRestore: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "rectangle.3.group")
                .foregroundColor(.accentColor)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(profile.name)
                    .fontWeight(.medium)
                Text("\(profile.windows.count) windows on \(profile.screens.count) screen\(profile.screens.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isHovered {
                HStack(spacing: 4) {
                    SmallIconButton(icon: "pencil", action: onRename)
                    SmallIconButton(icon: "trash", action: onDelete)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .background(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onRestore()
        }
    }
}

// MARK: - Reusable Components

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .frame(width: 16)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct SmallIconButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.borderless)
    }
}

// MARK: - Save Profile Sheet

struct SaveProfileSheet: View {
    @Binding var profileName: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Save Current Layout")
                .font(.headline)

            TextField("Profile name", text: $profileName)
                .textFieldStyle(.roundedBorder)
                .onSubmit { onSave() }

            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save", action: onSave)
                    .keyboardShortcut(.defaultAction)
                    .disabled(profileName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 280)
    }
}

// MARK: - Rename Profile Sheet

struct RenameProfileSheet: View {
    @Binding var profileName: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Rename Profile")
                .font(.headline)

            TextField("New name", text: $profileName)
                .textFieldStyle(.roundedBorder)
                .onSubmit { onSave() }

            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Rename", action: onSave)
                    .keyboardShortcut(.defaultAction)
                    .disabled(profileName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 280)
    }
}
