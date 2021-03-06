import MapKit

public final class Factory {
    struct Shot {
        var options = MKMapSnapshotter.Options()
        var x = 0
        var y = 0
        var z = 0
        var w = 0
        var h = 0
        
        mutating func update(_ size: Double) {
            options.dark()
            options.mapType = .standard
            options.size = .init(width: Argonaut.tile * .init(w), height: Argonaut.tile * .init(h))
            options.mapRect = .init(x: .init(x) * size, y: .init(y) * size, width: .init(w) * size, height: .init(h) * size)
        }
    }
    
    struct Split {
        var data = Data()
        var x = 0
        var y = 0
    }
    
    public var error: ((Error) -> Void)!
    public var progress: ((Float) -> Void)!
    public var complete: ((Session.Item) -> Void)!
    public var path = [Path]()
    public var rect = MKMapRect()
    public var mode = Session.Mode.walking
    var range = (0 ... 0)
    private(set) var shots = [Shot]()
    let item = Session.Item()
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private let margin = 0.001
    private let padding = 2
    private let queue = DispatchQueue(label: "", qos: .userInteractive, target: .global(qos: .userInteractive))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    private let out = OutputStream(url: Argonaut.temporal, append: false)!
    
    public init() {
        out.open()
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            self?.shooter?.cancel()
            DispatchQueue.main.async { [weak self] in self?.error(Fail("Mapping timed out.")) }
        }
    }
    
    deinit { out.close() }
    
    public func filter() {
        path.forEach { $0.options.removeAll { $0.mode != mode } }
        if mode == .flying {
            range = (2 ... 12)
        } else {
            range = (13 ... 19)
        }
    }
    
    public func measure() {
        rect = {
            {
                if $0.isEmpty { return rect }
                let rect = {
                    .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y)
                } (MKMapPoint(.init(latitude: $0.first!.0 + margin, longitude: $1.first!.1 - margin)),
                   MKMapPoint(.init(latitude: $0.last!.0 - margin, longitude: $1.last!.1 + margin))) as MKMapRect
                return rect
            } ($0.sorted { $0.0 > $1.0 }, $0.sorted { $0.1 < $1.1 })
        } (path.flatMap { $0.options.flatMap { $0.points } })
    }
    
    public func divide() {
        range.forEach { z in
            if z == 2 {
                (-1 ..< 3).forEach { x in
                    (0 ..< 2).forEach { y in
                        var shot = Shot()
                        shot.x = x
                        shot.y = y * 2
                        shot.z = z
                        shot.w = 2
                        shot.h = 2
                        shot.update(MKMapRect.world.width / 4)
                        shots.append(shot)
                    }
                }
            } else {
                let max = Int(min(pow(2, Double(z - 1)), 10))
                let proportion = MKMapRect.world.width / pow(2, .init(z))
                var minX = Int(rect.minX / proportion) - padding
                let minY = Int(rect.minY / proportion) - padding
                let maxX = Int(ceil(rect.maxX / proportion)) + padding
                let maxY = Int(ceil(rect.maxY / proportion)) + padding
                
                while minX < maxX {
                    var y = minY
                    let w = min(maxX - minX, max - 1)
                    while y < maxY {
                        var shot = Shot()
                        shot.x = minX - 1
                        shot.y = y
                        shot.z = z
                        shot.w = w + 1
                        shot.h = min(maxY - y, max)
                        shot.update(proportion)
                        shots.append(shot)
                        y += shot.h
                    }
                    minX += w
                }
            }
        }
        total = .init(shots.count)
    }
    
    public func register() {
        item.mode = mode
        item.points = path.compactMap { $0.name.isEmpty ? nil : $0.name }
        path.forEach {
            $0.options.forEach {
                item.duration += $0.duration
                item.distance += $0.distance
            }
        }
    }
    
    public func shoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let shot = self.shots.last else { return }
            self.progress((self.total - .init(self.shots.count)) / self.total)
            self.timer.schedule(deadline: .now() + 22)
            let shooter = MKMapSnapshotter(options: shot.options)
            self.shooter = shooter
            shooter.start(with: self.queue) { [weak self] in
                guard let self = self else { return }
                self.timer.schedule(deadline: .distantFuture)
                do {
                    if let error = $1 {
                        throw error
                    } else if let result = $0 {
                        self.shots.removeLast()
                        self.shoot()
                        self.chunk(result.image.split(shot), z: shot.z)
                        if self.shots.isEmpty {
                            self.out.close()
                            Argonaut.save(self)
                            DispatchQueue.main.async { [weak self] in
                                guard let item = self?.item else { return }
                                self?.complete(item)
                            }
                        }
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    DispatchQueue.main.async { [weak self] in self?.error(error) }
                }
            }
        }
    }
    
    func chunk(_ split: [Split], z: Int) {
        split.forEach {
            _ = withUnsafeBytes(of: UInt8(z)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
            _ = [UInt32($0.x), UInt32($0.y), UInt32($0.data.count)].withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 12) }
            _ = $0.data.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
        }
    }
}
