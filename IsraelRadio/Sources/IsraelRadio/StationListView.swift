import SwiftUI

struct StationListView: View {
    let stations: [RadioStation]
    @ObservedObject var player: RadioPlayer
    @ObservedObject var favorites: FavoritesManager
    @State private var searchText = ""

    private var favoriteStations: [RadioStation] {
        favorites.favorites(from: stations)
    }

    private var filteredStations: [RadioStation] {
        if searchText.isEmpty { return stations }
        return stations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            nowPlayingBar
            searchBar
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    if searchText.isEmpty && !favoriteStations.isEmpty {
                        favoritesSection
                        Divider().padding(.vertical, 4)
                    }
                    allStationsSection
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 300, maxHeight: 400)
            Divider()
            quitButton
        }
        .frame(width: 300, height: 450)
    }

    // MARK: - Now Playing

    private var nowPlayingBar: some View {
        Group {
            if let station = player.currentStation {
                HStack {
                    if player.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.trailing, 2)
                    } else {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundStyle(.green)
                    }
                    Text(station.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        player.stop()
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("חיפוש תחנה...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Favorites Section

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("מועדפים")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.bottom, 2)
            ForEach(favoriteStations) { station in
                stationRow(station)
            }
        }
    }

    // MARK: - All Stations

    private var allStationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if searchText.isEmpty {
                Text("כל התחנות")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 2)
            }
            ForEach(filteredStations) { station in
                stationRow(station)
            }
        }
    }

    // MARK: - Station Row

    private func stationRow(_ station: RadioStation) -> some View {
        Button {
            player.toggle(station: station)
        } label: {
            HStack {
                Button {
                    favorites.toggle(station)
                } label: {
                    Image(systemName: favorites.isFavorite(station) ? "star.fill" : "star")
                        .foregroundStyle(favorites.isFavorite(station) ? .yellow : .secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)

                Text(station.name)
                    .lineLimit(1)
                    .font(.system(size: 13))

                Spacer()

                if player.currentStation == station {
                    if player.isLoading {
                        ProgressView()
                            .controlSize(.mini)
                    } else if player.isPlaying {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 11))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            player.currentStation == station
                ? Color.accentColor.opacity(0.15)
                : Color.clear
        )
        .cornerRadius(4)
        .padding(.horizontal, 4)
    }

    // MARK: - Quit

    private var quitButton: some View {
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            HStack {
                Text("יציאה")
                Spacer()
                Text("⌘Q")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
