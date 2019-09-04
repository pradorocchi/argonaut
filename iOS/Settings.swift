import UIKit

final class Settings: UIView {
    class func show() {
        guard !app.view.subviews.contains(where: { $0 is Settings }) else { return }
        let settings = Settings()
        app.view.addSubview(settings)
        
        settings.leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        settings.rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        settings.topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        settings.bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        
        app.view.layoutIfNeeded()
        settings.top.constant = -10
        UIView.animate(withDuration: 0.4) {
            settings.alpha = 1
            app.view.layoutIfNeeded()
        }
    }
    
    private weak var top: NSLayoutConstraint!
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        alpha = 0
        backgroundColor = .init(white: 0, alpha: 0.6)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 6
        addSubview(base)
        
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.heightAnchor.constraint(equalToConstant: 480).isActive = true
        top = base.topAnchor.constraint(equalTo: topAnchor, constant: -490)
        top.isActive = true
    }
    
    @objc private func close() {
        top.constant = -490
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            app.view.layoutIfNeeded()
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
