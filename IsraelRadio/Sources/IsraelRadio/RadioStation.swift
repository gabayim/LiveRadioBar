import Foundation
import Compression

struct RadioStation: Identifiable, Hashable {
    let id: String
    let name: String
    let url: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        lhs.id == rhs.id
    }
}

enum M3UParser {
    static func parse(content: String) -> [RadioStation] {
        var stations: [RadioStation] = []
        let lines = content.components(separatedBy: .newlines)
        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("#EXTINF:") {
                if let commaIndex = line.firstIndex(of: ",") {
                    let name = String(line[line.index(after: commaIndex)...])
                        .trimmingCharacters(in: .whitespaces)
                    i += 1
                    while i < lines.count {
                        let urlLine = lines[i].trimmingCharacters(in: .whitespaces)
                        if !urlLine.isEmpty && !urlLine.hasPrefix("#") {
                            if let url = URL(string: urlLine) {
                                stations.append(RadioStation(id: name, name: name, url: url))
                            }
                            break
                        }
                        i += 1
                    }
                }
            }
            i += 1
        }
        return stations
    }

    static func loadBundled() -> [RadioStation] {
        guard let content = StationData.decode() else { return [] }
        return parse(content: content)
    }
}

// MARK: - Obfuscated station data (zlib-compressed, base64-encoded M3U)

private enum StationData {
    static let encoded = """
    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
    """

    static func decode() -> String? {
        let clean = encoded
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
        guard let compressed = Data(base64Encoded: clean) else { return nil }
        return zlibDecompress(compressed)
    }

    private static func zlibDecompress(_ data: Data) -> String? {
        // zlib compressed data: strip 2-byte zlib header, decompress raw deflate
        guard data.count > 2 else { return nil }
        let deflateData = data.dropFirst(2)
        let bufferSize = 32_768
        var output = Data()

        let result: Data? = deflateData.withUnsafeBytes { srcRaw in
            guard let srcPtr = srcRaw.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
            let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { dstBuffer.deallocate() }

            let decodedSize = compression_decode_buffer(
                dstBuffer, bufferSize,
                srcPtr, deflateData.count,
                nil,
                COMPRESSION_ZLIB
            )
            guard decodedSize > 0 else { return nil }
            return Data(bytes: dstBuffer, count: decodedSize)
        }

        guard let decompressed = result else { return nil }
        output.append(decompressed)
        return String(data: output, encoding: .utf8)
    }
}
