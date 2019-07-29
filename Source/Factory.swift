import MapKit

public final class Factory {
    public var plan = [Route]()
    public var error: ((Error) -> Void)?
    public var progress: ((Float) -> Void)?
    public let id = UUID().uuidString
    var rect = MKMapRect()
    var shots = [MKMapSnapshotter.Options]()
    var range = (13 ... 20)
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private let margin = 0.002
    private let response = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private let crop = DispatchQueue(label: "", qos: .default, target: .global(qos: .default))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    public init() {
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            print("timeout")
            self?.shooter?.cancel()
            DispatchQueue.main.async { [weak self] in self?.error?(Fail("Mapping timed out.")) }
        }
    }
    
    public func measure() {
        rect = {{
            let rect = { .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $0.y - $1.y)} (MKMapPoint(.init(latitude: $0.first!.latitude - margin, longitude: $1.first!.longitude - margin)), MKMapPoint(.init(latitude: $0.last!.latitude + margin, longitude: $1.last!.longitude + margin))) as MKMapRect
            return rect
        } ($0.sorted(by: { $0.latitude < $1.latitude }), $0.sorted(by: { $0.longitude < $1.longitude }))} (plan.flatMap({ $0.path.flatMap({ UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { $0.coordinate }})}))
    }
    
    public func divide() {
        range.map({ ceil(1 / (Double(1 << $0) / 1048575)) * 256 }).forEach { tile in
            let w = Int(ceil(rect.width / tile))
            let h = Int(ceil(rect.height / tile))
            ({
                stride(from: $0, to: $0 + w, by: 10)
            } (max(0, Int(rect.minX / tile) - max(0, ((10 - w) / 2))))).forEach { x in
                ({
                    stride(from: $0, to: $0 + h, by: 10)
                } (max(0, Int(rect.minY / tile) - max(0, ((10 - h) / 2))))).forEach { y in
                    shots.append({
                        if #available(OSX 10.14, *) {
                            $0.appearance = NSAppearance(named: .darkAqua)
                        }
                        $0.mapType = .standard
                        $0.size = .init(width: 2560, height: 2560)
                        $0.mapRect = .init(x: Double(x) * tile, y: Double(y) * tile, width: tile * 10, height: tile * 10)
                        return $0
                    } (MKMapSnapshotter.Options()))
                }
            }
        }
        total = Float(shots.count)
    }
    
    public func shoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let shot = self.shots.last
            else {
                print("finished")
                return
            }
            print(shot.mapRect)
            self.progress?((self.total - Float(self.shots.count)) / self.total)
            self.timer.schedule(deadline: .now() + 6)
            let shooter = MKMapSnapshotter(options: shot)
            self.shooter = shooter
            shooter.start(with: self.response) { [weak self] in
                self?.timer.schedule(deadline: .distantFuture)
                do {
                    if let error = $1 {
                        throw error
                    } else if let result = $0 {
                        self?.crop.async {
                            let url = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".png")
                            try! NSBitmapImageRep(cgImage: result.image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])!.write(to: url)
                            print(url)
                        }
                        self?.shots.removeLast()
                        self?.shoot()
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    print(error)
                    DispatchQueue.main.async { [weak self] in self?.error?(error) }
                }
            }
        }
    }
}
