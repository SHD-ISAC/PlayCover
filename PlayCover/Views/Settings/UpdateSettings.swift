//
//  UpdateSettings.swift
//  PlayCover
//
//  Created by Andrew Glaze on 7/23/22.
//

import Sparkle
import SwiftUI

struct UpdateSettings: View {
    @ObservedObject var updaterViewModel: UpdaterViewModel
    @AppStorage("SUEnableAutomaticChecks") var autoUpdate = false

    var body: some View {
        Form {
            if updaterViewModel.isForkDistribution {
                Text("Automatic updates are disabled for this unnotarized fork.")
                if let url = URL(string: "https://github.com/SHD-ISAC/PlayCover/releases") {
                    Link("Check fork Releases manually", destination: url)
                }
            } else {
                Toggle("preferences.toggle.automaticUpdates", isOn: $autoUpdate)
                Button("preferences.button.checkForUpdates") {
                    updaterViewModel.checkForUpdates()
                }
            }
        }
        .padding(20)
        .frame(width: 600, height: updaterViewModel.isForkDistribution ? 120 : 100, alignment: .center)
        .onChange(of: autoUpdate) { value in
            guard !updaterViewModel.isForkDistribution else { return }
            updaterViewModel.automaticallyCheckForUpdates = value
        }
    }
}
