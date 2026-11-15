//
//  Sparkle.swift
//  PlayCover
//
//  Created by Andrew Glaze on 7/17/22.
//  Copied from https://sparkle-project.org/documentation/programmatic-setup/
//

import Sparkle
import SwiftUI

// This view model class manages Sparkle's updater and publishes when new updates are allowed to be checked
final class UpdaterViewModel: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    // Test fork bundles must never follow the upstream Sparkle update feed.
    let isForkDistribution: Bool =
        (Bundle.main.object(forInfoDictionaryKey: "PlayCoverForkDistribution") as? String) == "unnotarized"

    @Published var canCheckForUpdates = false

    var automaticallyCheckForUpdates: Bool {
        get {
            !isForkDistribution && updaterController.updater.automaticallyChecksForUpdates
        }
        set(newValue) {
            guard !isForkDistribution else { return }
            updaterController.updater.automaticallyChecksForUpdates = newValue
        }
    }

    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(
            startingUpdater: !isForkDistribution,
            updaterDelegate: nil,
            userDriverDelegate: nil)

        if !isForkDistribution {
            updaterController.updater.publisher(for: \.canCheckForUpdates)
                .assign(to: &$canCheckForUpdates)

            if automaticallyCheckForUpdates {
                updaterController.updater.checkForUpdatesInBackground()
            }
        }
    }

    func checkForUpdates() {
        guard !isForkDistribution else { return }
        updaterController.checkForUpdates(nil)
    }
}

// This additional view is needed for the disabled state on the menu item to work properly before Monterey.
// See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more information
struct CheckForUpdatesView: View {
    @ObservedObject var updaterViewModel: UpdaterViewModel

    var body: some View {
        Button(NSLocalizedString("menubar.checkForUpdates", comment: ""),
               systemImage: "arrow.trianglehead.2.clockwise.rotate.90",
               action: updaterViewModel.checkForUpdates)
            .disabled(!updaterViewModel.canCheckForUpdates)
    }
}
