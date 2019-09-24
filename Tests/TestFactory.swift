@testable import Argonaut
import XCTest
import MapKit

final class TestFactory: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testEmptyPlan() {
        factory.measure()
    }
    
    func testMeasure() {
        factory.path = [.init()]
        factory.path[0].options = [.init()]
        factory.path[0].options[0].points = [(-50, 60), (70, -80), (-30, 20), (82, -40)]
        factory.measure()
        XCTAssertEqual(-80.002, factory.rect.origin.coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(82.002, factory.rect.origin.coordinate.latitude, accuracy: 0.00001)
        XCTAssertEqual(60.002, MKMapPoint(x: factory.rect.maxX, y: 0).coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(-50.002, MKMapPoint(x: 0, y: factory.rect.maxY).coordinate.latitude, accuracy: 0.00001)
    }
    
    func testDivide1() {
        factory.rect.size.width = 5120
        factory.rect.size.height = 5120
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(25, factory.shots.count)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minY)
        XCTAssertEqual(1024, factory.shots.first?.options.mapRect.maxX)
        XCTAssertEqual(1024, factory.shots.first?.options.mapRect.maxY)
        XCTAssertEqual(512, factory.shots.first?.options.size.width)
        XCTAssertEqual(512, factory.shots.first?.options.size.height)
    }
    
    func testDivideMin() {
        factory.rect.origin.x = 5119
        factory.rect.origin.y = 5119
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
    }
    
    func testDivide4() {
        factory.rect.size.width = 5121
        factory.rect.size.height = 5121
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(36, factory.shots.count)
    }
    
    func testDivideCentred() {
        factory.rect.origin.x = 2559
        factory.rect.origin.y = 2559
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(2048, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(2048, factory.shots.first?.options.mapRect.minY)
        XCTAssertEqual(3072, factory.shots.first?.options.mapRect.maxX)
        XCTAssertEqual(3072, factory.shots.first?.options.mapRect.maxY)
    }
    
    func testDivideByMax() {
        factory.rect.size.width = MKMapRect.world.width / 32
        factory.rect.size.height = MKMapRect.world.width / 256
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(MKMapRect.world.width / 32, factory.shots[0].options.mapRect.width)
    }
    
    func testRegister() {
        factory.mode = .flying
        factory.path = [.init(), .init(), .init()]
        factory.path[0].name = "hello"
        factory.path[0].options = [.init()]
        factory.path[0].options[0].duration = 1
        factory.path[0].options[0].distance = 2
        factory.path[0].options[0].mode = .flying
        factory.path[1].name = "world"
        factory.path[1].options = [.init()]
        factory.path[1].options[0].duration = 1
        factory.path[1].options[0].distance = 2
        factory.path[1].options[0].mode = .flying
        factory.path[2].name = "lorem"
        factory.path[2].options = [.init()]
        factory.path[2].options[0].duration = 3
        factory.path[2].options[0].distance = 2
        factory.path[2].options[0].mode = .flying
        factory.register()
        XCTAssertEqual(.flying, factory.item.mode)
        XCTAssertEqual("hello", factory.item.points[0])
        XCTAssertEqual("world", factory.item.points[1])
        XCTAssertEqual("lorem", factory.item.points[2])
        XCTAssertEqual(5, factory.item.duration)
        XCTAssertEqual(6, factory.item.distance)
    }
    
    func testRegisterEmpty() {
        factory.register()
        XCTAssertTrue(factory.item.points.isEmpty)
    }
    
    func testRegisterNameNonEmpty() {
        factory.path = [.init(), .init()]
        factory.path[0].name = "hello"
        factory.register()
        XCTAssertEqual(1, factory.item.points.count)
    }
    
    func testRange() {
        factory.mode = .driving
        factory.filter()
        XCTAssertEqual(12, factory.range.min()!)
        XCTAssertEqual(18, factory.range.max()!)
        
        factory.mode = .flying
        factory.filter()
        XCTAssertEqual(1, factory.range.min()!)
        XCTAssertEqual(7, factory.range.max()!)
    }
    
    func testDivideFlight1() {
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (1 ... 1)
        factory.divide()
        XCTAssertEqual(4, factory.shots.count)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minY)
    }
}
