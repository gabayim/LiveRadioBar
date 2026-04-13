import Foundation

@MainActor
final class FavoritesManager: ObservableObject {
    private static let key = "favoriteStationIDs"

    @Published var favoriteIDs: Set<String> {
        didSet { save() }
    }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
        self.favoriteIDs = Set(saved)
    }

    func isFavorite(_ station: RadioStation) -> Bool {
        favoriteIDs.contains(station.id)
    }

    func toggle(_ station: RadioStation) {
        if favoriteIDs.contains(station.id) {
            favoriteIDs.remove(station.id)
        } else {
            favoriteIDs.insert(station.id)
        }
    }

    func favorites(from stations: [RadioStation]) -> [RadioStation] {
        stations.filter { favoriteIDs.contains($0.id) }
    }

    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: Self.key)
    }
}
