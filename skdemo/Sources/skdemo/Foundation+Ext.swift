import Foundation

extension Encodable {
    func prettyPrinted(withEncoder encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let previousEncoding = encoder.outputFormatting
        defer {
            encoder.outputFormatting = previousEncoding
        }
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
