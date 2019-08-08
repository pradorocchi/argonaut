import Argonaut
import AppKit

final class List: NSWindow {
    var session: Session! { didSet { refresh() } }
    
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 600, y: NSScreen.main!.frame.midY - 400, width: 300, height: 800), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let new = Button.Image(self, action: #selector(self.new))
        new.image.image = NSImage(named: "new")
        contentView!.addSubview(new)
        
        new.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        new.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        new.widthAnchor.constraint(equalToConstant: 40).isActive = true
        new.heightAnchor.constraint(equalToConstant: 40).isActive = true
        Session.load {
            self.session = $0
        }
    }
    
    override func close() {
        super.close()
        app.terminate(nil)
    }
    
    @objc func new() {
        if let new = app.windows.first(where: { $0 is New }) {
            new.orderFront(nil)
        } else {
            New().makeKeyAndOrderFront(nil)
        }
    }
    
    private func refresh() {
        
    }
}
