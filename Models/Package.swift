import Foundation

struct Package: Codable, Identifiable {
    let id: UUID
    let trackingNumber: String
    let length: Double
    let width: Double
    let height: Double
    let unit: String
    let images: [String]
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case trackingNumber = "tracking_number"
        case length
        case width
        case height
        case unit
        case images
        case timestamp
    }
}
