import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

@main
struct IsraelRadioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var player = RadioPlayer()
    @StateObject private var favorites = FavoritesManager()
    private let stations = M3UParser.loadBundled()

    var body: some Scene {
        MenuBarExtra {
            StationListView(
                stations: stations,
                player: player,
                favorites: favorites
            )
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        if let station = player.currentStation {
            Label(station.name, systemImage: "antenna.radiowaves.left.and.right")
        } else {
            Label("Radio", systemImage: "radio")
        }
    }
}
