import Argonaut
import MapKit

final class Line: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    private(set) weak var path: Plan.Path!
    private(set) weak var option: Plan.Option!
    let point: [MKMapPoint]
    
    init(_ path: Plan.Path, option: Plan.Option) {
        self.path = path
        self.option = option
        point = option.points.map { MKMapPoint(.init(latitude: $0.0, longitude: $0.1)) }
        boundingMapRect = {
            .init(x: $0.first!.x, y: $1.first!.y, width: $0.last!.x - $0.first!.x, height: $1.last!.y - $1.first!.y)
        } (point.sorted (by: { $0.x < $1.x }), point.sorted (by: { $0.y < $1.y }))
        coordinate = .init(latitude: boundingMapRect.midX, longitude: boundingMapRect.midY)
        super.init()
    }
    
//    func intersects(_ mapRect: MKMapRect) -> Bool { return boundingMapRect.intersects(mapRect) }
}
