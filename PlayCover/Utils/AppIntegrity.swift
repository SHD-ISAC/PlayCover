//
//  AppIntegrity.swift
//  PlayCover
//

import Foundation

class AppIntegrity: ObservableObject {

    @Published var integrityOff: Bool = !AppIntegrity.insideAppsFolder

    func verifyAppIntegrity() {
        integrityOff = !AppIntegrity.insideAppsFolder
    }

    func moveToApps() {
        guard let source = AppIntegrity.appUrl else { return }

        // A test build may be named PlayCover-SecurityTest.app, so check the
        // containing directory instead of requiring /Applications/PlayCover.app.
        if AppIntegrity.insideAppsFolder {
            integrityOff = false
            return
        }

        // Preserve the bundle name. Do not replace a production installation
        // with a differently named test build, or silently remove any existing app.
        guard source.pathExtension.lowercased() == "app" else { return }
        let destination = AppIntegrity.applicationsFolder
            .appendingPathComponent(source.lastPathComponent, isDirectory: true)

        do {
            guard !FileManager.default.fileExists(atPath: destination.path) else {
                throw CocoaError(.fileWriteFileExists)
            }
            try FileManager.default.moveItem(at: source, to: destination)
            destination.openInFinder()
            exit(0)
        } catch {
            Log.shared.error(error)
        }
    }

    private static var appUrl: URL? {
        Bundle.main.bundleURL
    }

    private static let applicationsFolder = URL(fileURLWithPath: "/Applications", isDirectory: true)

    private static var insideAppsFolder: Bool {
        guard let url = appUrl else { return false }

        // Preserve development builds launched from Xcode without treating
        // unrelated paths containing "/Applications" as installed apps.
        if url.path.contains("Xcode") {
            return true
        }
        return url.deletingLastPathComponent().resolvingSymlinksInPath().standardizedFileURL ==
            applicationsFolder.resolvingSymlinksInPath().standardizedFileURL
    }
}
