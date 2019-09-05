import Foundation

public class Session: Codable {
    public enum Map: Int, Codable {
        case argonaut
        case apple
        case hybrid
    }
    
    public enum Mode: Int, Codable {
        case flight
        case ground
    }
    
    public struct Travel: Codable {
        public var duration = 0.0
        public var distance = 0.0
    }
    
    public class Item: Codable {
        public var id = ""
        public var title = ""
        public var origin = ""
        public var destination = ""
        public var mode = Mode.ground
        public var walking = Travel()
        public var driving = Travel()
        
        public init() { }
    }
    
    public struct Settings: Codable {
        public var map = Map.hybrid
        public var marks = true
        public var driving = true
        public var walking = true
        public var follow = true
    }
    
    public static func load(_ result: @escaping((Session) -> Void)) {
        queue.async {
            let session = {
                $0 == nil ? Session() : (try? JSONDecoder().decode(Session.self, from: $0!)) ?? Session()
            } (UserDefaults.standard.data(forKey: "session"))
            DispatchQueue.main.async { result(session) }
        }
    }
    
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    public var items = [Item]()
    public var settings = Settings()
    public var onboard = [String: Bool]()
    public var rating = Calendar.current.date(byAdding: {
        var d = DateComponents()
        d.day = 3
        return d
    } (), to: Date())!
    
    public func save() {
        Session.queue.async {
            UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session")
        }
    }
    
    public func update(_ item: Item) {
        items.removeAll { $0.id == item.id }
        items.append(item)
    }
}
