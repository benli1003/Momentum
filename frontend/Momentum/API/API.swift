
import Foundation

struct Task: Codable, Identifiable {
    let id: Int
    let user: Int
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case user
        case title
        case isCompleted = "is_completed"
        case dueDate = "due_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

