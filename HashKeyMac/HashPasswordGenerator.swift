import CryptoKit
import Foundation

enum HashPasswordGenerator {
    struct Output {
        let fullHex: String
        let shortGrouped: String
    }

    static func generate(from plainText: String, key: String) -> Output {
        let normalizedInput = plainText.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = Data(normalizedInput.utf8)
        let secret = SymmetricKey(data: Data(key.utf8))
        let digest = HMAC<SHA256>.authenticationCode(for: payload, using: secret)
        let fullHex = digest.map { String(format: "%02x", $0) }.joined()
        let shortHex = String(fullHex.prefix(16))
        let shortGrouped = stride(from: 0, to: shortHex.count, by: 4).map { startIndex in
            let start = shortHex.index(shortHex.startIndex, offsetBy: startIndex)
            let end = shortHex.index(start, offsetBy: 4, limitedBy: shortHex.endIndex) ?? shortHex.endIndex
            return String(shortHex[start..<end])
        }
        .joined(separator: "-")

        return Output(fullHex: fullHex, shortGrouped: shortGrouped)
    }
}
