# Israel Radio - macOS Menu Bar App

A lightweight macOS menu bar app for streaming Israeli radio stations. Click the radio icon in your menu bar, pick a station, and listen — no browser needed.

## Features

- **86 Israeli radio stations**
- **Menu bar only** — no Dock icon, no window clutter
- **Now playing** — current station name shown in the menu bar
- **Favorites** — star stations to pin them at the top of the list
- **Search** — filter stations by name in Hebrew or English
- **All stream types** — handles MP3, AAC, and HLS (`.m3u8`) natively via AVPlayer

## Requirements

- macOS 14 (Sonoma) or later
- Xcode Command Line Tools or Xcode (for building from source)

## Install

### Quick install (build + copy to Applications)

```bash
cd IsraelRadio
bash build_app.sh
```

This builds a release binary, packages it as `IsraelRadio.app` with an icon and `Info.plist`, and places it in `/Applications`. Launch it from Spotlight, Launchpad, or Finder.

### Development mode

```bash
cd IsraelRadio
swift run
```

## Start at Login

1. Open **System Settings > General > Login Items**
2. Click **+** under "Open at Login"
3. Select `/Applications/IsraelRadio.app`

## Project Structure

```
IsraelRadio/
├── Package.swift                      # SPM manifest (macOS 14+)
├── build_app.sh                       # Builds release .app bundle
├── README.md
└── Sources/IsraelRadio/
    ├── IsraelRadioApp.swift           # App entry, MenuBarExtra setup
    ├── RadioStation.swift             # Station model, M3U parser, embedded data
    ├── RadioPlayer.swift              # AVPlayer wrapper (play/stop/toggle)
    ├── FavoritesManager.swift         # UserDefaults-backed favorites
    └── StationListView.swift          # SwiftUI menu bar panel UI
```

## How It Works

1. Station data is embedded in the binary as a compressed and encoded blob — no plaintext URLs in source.
2. On launch, the data is decoded and decompressed into an M3U playlist, then parsed into station objects.
3. A `MenuBarExtra` with `.window` style renders the station list as a rich SwiftUI popover.
4. Tapping a station creates an `AVPlayerItem` from the stream URL and plays it via `AVPlayer`.
5. The menu bar label updates to show the currently playing station name.
6. Favorites are persisted to `UserDefaults` and shown in a dedicated section at the top.

## Updating Stations

To update the station list:

1. Prepare an M3U file with the new stations in standard format:
   ```
   #EXTM3U
   #EXTINF:-1,Station Name
   https://stream-url.example.com/live
   ```
2. Compress and encode it:
   ```bash
   python3 -c "
   import base64, zlib
   with open('stations.m3u', 'rb') as f:
       print(base64.b64encode(zlib.compress(f.read(), 9)).decode())
   "
   ```
3. Replace the `encoded` string in `RadioStation.swift` with the output.
4. Rebuild with `bash build_app.sh`.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 6 |
| UI | SwiftUI (`MenuBarExtra`) |
| Audio | AVFoundation (`AVPlayer`) |
| Build | Swift Package Manager |
| Persistence | `UserDefaults` |
