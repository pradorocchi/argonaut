import UIKit
import CoreLocation

class World: UIView, CLLocationManagerDelegate {
    let dater = DateComponentsFormatter()
    private(set) weak var map: Map!
    private(set) weak var list: Scroll!
    private(set) weak var _up: Button!
    private(set) weak var _close: UIButton!
    private(set) weak var top: Gradient.Top!
    private weak var _down: Button!
    private weak var _walking: Button!
    private weak var _driving: Button!
    private weak var _follow: Button!
    private weak var listTop: NSLayoutConstraint!
    private weak var walkingRight: NSLayoutConstraint!
    private weak var drivingRight: NSLayoutConstraint!
    private var formatter: Any!
    private let manager = CLLocationManager()
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .black
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        manager.delegate = self
        manager.stopUpdatingHeading()
        manager.startUpdatingHeading()
        
        if #available(iOS 10, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        map.setUserTrackingMode(.followWithHeading, animated: true)
        addSubview(map)
        self.map = map
        
        let top = Gradient.Top()
        addSubview(top)
        self.top = top
        
        let bottom = Gradient.Bottom()
        addSubview(bottom)
        
        let _close = UIButton()
        _close.translatesAutoresizingMaskIntoConstraints = false
        _close.isAccessibilityElement = true
        _close.accessibilityLabel = .key("Close")
        _close.setImage(UIImage(named: "close"), for: .normal)
        _close.imageView!.clipsToBounds = true
        _close.imageView!.contentMode = .center
        _close.addTarget(app, action: #selector(app.pop), for: .touchUpInside)
        addSubview(_close)
        self._close = _close
        
        let _walking = Button("walking")
        _walking.accessibilityLabel = .key("World.walking")
        _walking.addTarget(self, action: #selector(walking), for: .touchUpInside)
        _walking.isHidden = true
        addSubview(_walking)
        self._walking = _walking
        
        let _driving = Button("driving")
        _driving.accessibilityLabel = .key("World.driving")
        _driving.addTarget(self, action: #selector(driving), for: .touchUpInside)
        _driving.isHidden = true
        addSubview(_driving)
        self._driving = _driving
        
        let _down = Button("down")
        _down.accessibilityLabel = .key("World.down")
        _down.addTarget(self, action: #selector(down), for: .touchUpInside)
        _down.isHidden = true
        addSubview(_down)
        self._down = _down
        
        let _up = Button("up")
        _up.accessibilityLabel = .key("World.up")
        _up.addTarget(self, action: #selector(up), for: .touchUpInside)
        addSubview(_up)
        self._up = _up
        
        let _follow = Button("follow")
        _follow.accessibilityLabel = .key("World.follow")
        _follow.addTarget(self, action: #selector(follow), for: .touchUpInside)
        _follow.isEnabled = false
        _follow.active = false
        addSubview(_follow)
        self._follow = _follow
        
        let list = Scroll()
        list.backgroundColor = .black
        addSubview(list)
        self.list = list
        
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        top.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        bottom.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        bottom.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        _up.bottomAnchor.constraint(lessThanOrEqualTo: list.topAnchor).isActive = true
        
        _down.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _down.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        
        _follow.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _follow.rightAnchor.constraint(equalTo: _walking.leftAnchor).isActive = true
        
        _walking.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        walkingRight = _walking.centerXAnchor.constraint(equalTo: _up.centerXAnchor)
        walkingRight.isActive = true
        
        _driving.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        drivingRight = _driving.centerXAnchor.constraint(equalTo: _up.centerXAnchor)
        drivingRight.isActive = true
        
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        listTop = list.topAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        listTop.isActive = true
        
        if #available(iOS 11.0, *) {
            _up.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            _up.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool { true }
    func locationManager(_: CLLocationManager, didFailWithError: Error) { }
    func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) { }
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        switch didChangeAuthorization {
            case .denied: app.alert(.key("Error"), message: .key("Error.location"))
            case .notDetermined: manager.requestWhenInUseAuthorization()
            default: initial()
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0, let user = map.annotations.first(where: { $0 === map.userLocation }), let view = map.view(for: user) as? User else { return }
        UIView.animate(withDuration: 0.5) {
            view.heading?.transform = .init(rotationAngle: .init(didUpdateHeading.trueHeading) * .pi / 180)
        }
    }
    
    func refresh() { }
    
    final func measure(_ distance: CLLocationDistance) -> String {
        if #available(iOS 10, *) {
            return (formatter as! MeasurementFormatter).string(from: .init(value: distance, unit: UnitLength.meters))
        }
        return "\(Int(distance))" + .key("New.distance")
    }
    
    private func initial() {
        _follow.isEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.follow()
        }
    }
    
    @objc final func follow() {
        map.follow()
        _follow.active = map._follow
    }
    
    @objc final func walking() {
        map.walking()
        _walking.active = map._walking
        refresh()
    }
    
    @objc final func driving() {
        map.driving()
        _driving.active = map._driving
        refresh()
    }
    
    @objc private func up() {
        listTop.constant = -list.frame.height
        walkingRight.constant = -140
        drivingRight.constant = -70
        _walking.isHidden = false
        _driving.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._up.isHidden = true
            self?._down.isHidden = false
        }
    }
    
    @objc private func down() {
        listTop.constant = 0
        walkingRight.constant = 0
        drivingRight.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._walking.isHidden = true
            self?._driving.isHidden = true
            self?._up.isHidden = false
            self?._down.isHidden = true
        }
    }
}
