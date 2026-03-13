import Foundation

struct HookEvent: Codable {
    let sessionId: String?
    let transcriptPath: String?
    let hookEventName: String?
    let message: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case transcriptPath = "transcript_path"
        case hookEventName = "hook_event_name"
        case message, title
    }
}
