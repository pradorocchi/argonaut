/*import Argonaut
import MapKit

final class Create: NSWindow {
    private weak var progress: NSLayoutConstraint!
    private weak var button: Button.Yes!
    private weak var label: Label!
    private let factory = Factory()
    
    init(_ path: [Path], rect: MKMapRect) {
        super.init(contentRect: .init(origin: .init(x: NSScreen.main!.frame.maxX - 160, y: NSScreen.main!.frame.maxY - 123), size: .init(width: 160, height: 100)), styleMask: [.closable, .docModalWindow, .fullSizeContentView, .titled], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        level = .floating
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
        contentView!.addSubview(base)
        
        let progress = NSView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.wantsLayer = true
        progress.layer!.backgroundColor = .halo
        base.addSubview(progress)
        
        let button = Button.Yes(self, action: #selector(self.retry))
        button.label.stringValue = .key("Create.retry")
        button.isHidden = true
        contentView!.addSubview(button)
        self.button = button
        
        let label = Label("0%")
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .halo
        label.alignment = .right
        contentView!.addSubview(label)
        self.label = label
        
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        progress.topAnchor.constraint(equalTo: base.topAnchor, constant: 1).isActive = true
        progress.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -1).isActive = true
        progress.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 1).isActive = true
        self.progress = progress.widthAnchor.constraint(equalToConstant: 0)
        self.progress.isActive = true
        
        button.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 10).isActive = true
        button.bottomAnchor.constraint(equalTo: base.topAnchor, constant: -14).isActive = true
        
        label.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -15).isActive = true
        
        factory.path = path
        factory.rect = rect
        factory.error = { [weak self] in
            app.alert(.key("Error"), message: $0.localizedDescription)
            self?.button.isHidden = false
        }
        factory.complete = { [weak self] in self?.complete($0) }
        factory.progress = { [weak self] in
            self?.progress.constant = .init(160 * $0)
            self?.label.stringValue = "\(Int(100 * $0))%"
        }
        DispatchQueue.global(qos: .background).async { [weak self] in self?.start() }
    }
    
    private func start() {
        factory.filter()
        factory.measure()
        factory.divide()
        factory.register()
        DispatchQueue.main.async { [weak self] in self?.retry() }
    }
    
    private func complete(_ item: Session.Item) {
        app.session.items.append(item)
        app.session.save()
        app.list.refresh()
        close()
        Load(item.id).makeKeyAndOrderFront(nil)
    }
    
    @objc private func retry() {
        button.isHidden = true
        factory.shoot()
    }
}
*/