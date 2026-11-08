import Foundation
import SwiftData

/// SwiftData persistent entity for trusted support contacts.
/// Kept strictly on-device; calls are dispatched via the `tel:` URL scheme.
@Model
public final class SupportContact {
    public var id: UUID = UUID()
    public var name: String = ""
    public var phone: String = ""

    public var callURL: URL? {
        let digits = phone.replacingOccurrences(of: " ", with: "")
        return URL(string: "tel:\(digits)")
    }

    public init(id: UUID = UUID(), name: String, phone: String) {
        self.id = id
        self.name = name
        self.phone = phone
    }
}
