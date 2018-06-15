import Foundation
import UIKit

public struct CircularSectorContextSheetItem {
    public typealias Identifier = String
    let identifier: Identifier
    let title: String?
    let image: UIImage?
    let highlightedImage: UIImage?
    
    public init(identifier: Identifier, title: String? = nil, image: UIImage? = nil, highlightedImage: UIImage? = nil) {
        self.identifier = identifier
        self.title = title
        self.image = image
        self.highlightedImage = highlightedImage
    }
}

func orientedScreenBounds() -> CGRect {
    var bounds = UIScreen.main.bounds
    if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation), bounds.width < bounds.height {
        bounds.size = CGSize(width: bounds.height, height: bounds.width)
    }
    return bounds
}

func vectorDotProduct(_ vector1: CGPoint, _ vector2: CGPoint) -> CGFloat {
    return vector1.x * vector2.x + vector1.y * vector2.y
}

func vectorLength(_ vector: CGPoint) -> CGFloat{
    return sqrt(vector.x * vector.x + vector.y * vector.y)
}

public protocol CircularSectorContextSheetDelegate: AnyObject {
    func contextSheet(_ contextSheet: CircularSectorContextSheet, didSelect item: CircularSectorContextSheetItem.Identifier, userInfo: [String: Any]?)
}

open class CircularSectorContextSheet: UIView {
    open weak var delegate: CircularSectorContextSheetDelegate?
    open var maximumAngle = CGFloat.pi / 1.6
    open var maximumInteritemAngle = CGFloat.pi / 4
    open var maximumTouchDistance: CGFloat = 40

    var radius: CGFloat = 100
    var rotation: CGFloat = 0
    let items: [CircularSectorContextSheetItem]
    var itemViews: [CircularSectorContextSheetItemView] = []
    weak var centerView: UIView?
    weak var backgroundView: UIView?
    var selectedItemIndex: Int?
    var openAnimationFinished: Bool = false
    var touchCenter: CGPoint = CGPoint.zero
    var starterGestureRecognizer: UIGestureRecognizer?
    var userInfo: [String: Any]?
    
    public init(items: [CircularSectorContextSheetItem]) {
        self.items = items
        super.init(frame: orientedScreenBounds())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func start(gestureRecognizer: UIGestureRecognizer, in view: UIView, userInfo: [String: Any]? = nil) {
        if itemViews.count != items.count {
            self.reload()
        }
        self.userInfo = userInfo
        
        view.addSubview(self)
        
        frame = orientedScreenBounds()
        
        starterGestureRecognizer = gestureRecognizer
        
        touchCenter = gestureRecognizer.location(in: self)
        centerView?.center = touchCenter
        selectedItemIndex = nil
        setCenterViewHighlighted(true)
        rotation = rotationForCenter(touchCenter)
        
        openItemsFromCenterView()
        
        gestureRecognizer.addTarget(self, action: #selector(gestureRecognizedStateObserver(_:)))
    }
    
    open func end() {
        starterGestureRecognizer?.removeTarget(self, action: #selector(gestureRecognizedStateObserver(_:)))
        
        if let selectedItemIndex = selectedItemIndex, selectedItemIndex < items.count {
            delegate?.contextSheet(self, didSelect: items[selectedItemIndex].identifier, userInfo: userInfo)
            userInfo = nil
        }
        
        closeItemsToCenterView()
    }
    
    open func reload() {
        self.createSubviews()
    }
    
    @objc func gestureRecognizedStateObserver(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            if openAnimationFinished {
                let touchPoint = gestureRecognizer.location(in: self)
                updateItemViewsForTouchPoint(touchPoint)
            }
            
        case .ended:
            end()
            
        case .cancelled:
            selectedItemIndex = nil
            end()
            
        default:
            break
        }
    }
}

extension CircularSectorContextSheet {
    
    func createSubviews() {
        backgroundView?.removeFromSuperview()
        backgroundView = {
            let backgroundView = UIView(frame: bounds)
            backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.6)
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(backgroundView)
            return backgroundView
        }()
        
        _ = itemViews.map { itemView in
            itemView.removeFromSuperview()
        }
        itemViews = items.map { item in
            let itemView = CircularSectorContextSheetItemView(frame: CGRect(x: 0, y: 0, width: 50, height: 83))
            itemView.image = item.image
            itemView.highlightedImage = item.highlightedImage
            itemView.title = item.title
            addSubview(itemView)
            return itemView
        }
        
        centerView?.removeFromSuperview()
        centerView = {
            if let sampleItemView = itemViews.first {
                let centerView = UIView(frame: CGRect(x: 0, y: 0, width: sampleItemView.frame.width, height: sampleItemView.frame.width))
                centerView.layer.cornerRadius = 25
                centerView.layer.borderWidth = 2
                centerView.layer.borderColor = UIColor.gray.cgColor
                addSubview(centerView)
                return centerView
            }
            return nil
        }()
    }
    
    func setCenterViewHighlighted(_ highlighted: Bool) {
        centerView?.backgroundColor = highlighted ? UIColor(white: 0.5, alpha: 0.4) : nil
    }
    
    func update(itemView: CircularSectorContextSheetItemView, touchDistance: CGFloat, animated: Bool) {
        let fn = {
            let itemIndex = self.itemViews.index(of: itemView) ?? 0
            var interItemAngle: CGFloat = 0
            var maximumAngle: CGFloat = 0
            if self.itemViews.count >= 2 {
                interItemAngle = min(self.maximumInteritemAngle, self.maximumAngle / CGFloat(self.itemViews.count - 1))
                maximumAngle = interItemAngle * CGFloat(self.itemViews.count - 1)
            }
            let angle = self.rotation + maximumAngle / 2 - CGFloat(itemIndex) * interItemAngle
            let resistanceFactor: CGFloat = 1.0 / (touchDistance > 0 ? 6.0 : 3.0)
            let scale = 1 + 0.2 * fabs(touchDistance) / self.radius
            
            itemView.center = CGPoint(x: self.touchCenter.x + (self.radius + touchDistance * resistanceFactor) * sin(angle),
                                      y: self.touchCenter.y + (self.radius + touchDistance * resistanceFactor) * cos(angle))
            itemView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        if !animated {
            fn()
        } else {
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.45,
                           initialSpringVelocity: 7.5,
                           options: [.beginFromCurrentState],
                           animations: fn,
                           completion: nil)
        }
    }
    
    func openItemsFromCenterView() {
        openAnimationFinished = false
        
        for i in 0..<itemViews.count {
            let itemView = itemViews[i]
            itemView.transform = .identity
            itemView.center = touchCenter
            itemView.setHighlighted(false, animated: false)
            
            UIView.animate(withDuration: 0.5,
                           delay: Double(i) * 0.01,
                           usingSpringWithDamping: 0.45,
                           initialSpringVelocity: 7.5,
                           options: [],
                           animations: { self.update(itemView: itemView, touchDistance: 0, animated: false) },
                           completion: { _ in self.openAnimationFinished = true })
        }
    }
    
    func closeItemsToCenterView() {
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: { self.alpha = 0 },
                       completion: { _ in
                        self.removeFromSuperview()
                        self.alpha = 1
        })
    }
    
    func rotationForCenter(_ center: CGPoint) -> CGFloat {
        let widthA: CGFloat = 110
        let degreeA = self.maximumAngle / 2 + .pi / 8
        let rowHeight1: CGFloat = 120
        
        let degree = { () -> CGFloat in
            if center.x < widthA {
                // upper-left
                return degreeA * (widthA - center.x) / widthA
            } else if center.x >= bounds.width - widthA {
                // upper-right
                return -degreeA * (center.x - bounds.width + widthA) / widthA
            } else {
                // upper-center
                return 0
            }
        }()
        
        if center.y <= rowHeight1 {
            return degree
        } else {
            // lower
            return .pi - degree
        }
    }
    
    func signedTouchDistanceForTouchVector(_ touchVector: CGPoint, itemView: CircularSectorContextSheetItemView?) -> CGFloat {
        var touchDistance = vectorLength(touchVector)
        
        if let itemView = itemView {
            let oldCenter = itemView.center
            let oldTransform = itemView.transform
            
            self.update(itemView: itemView, touchDistance: radius + 40, animated: false)
            
            if !bounds.contains(itemView.frame) {
                touchDistance = -touchDistance
            }
            
            itemView.center = oldCenter
            itemView.transform = oldTransform
        }
        
        return touchDistance
    }
    
    func itemViewForTouchVector(_ touchVector: CGPoint) -> CircularSectorContextSheetItemView? {
        var maxCosOfAngle: CGFloat = -2
        var resultItemView: CircularSectorContextSheetItemView?
        
        for itemView in itemViews {
            let itemViewVector = CGPoint(x: itemView.center.x - touchCenter.x,
                                         y: itemView.center.y - touchCenter.y)
            
            let cosOfAngle: CGFloat = vectorDotProduct(itemViewVector, touchVector) / vectorLength(itemViewVector)
            
            if cosOfAngle > maxCosOfAngle {
                maxCosOfAngle = cosOfAngle
                resultItemView = itemView
            }
        }
        
        return resultItemView
    }
    
    func updateItemViewsForTouchPoint(_ touchPoint: CGPoint) {
        let touchVector = CGPoint(x: touchPoint.x - touchCenter.x, y: touchPoint.y - touchCenter.y)
        let itemView = itemViewForTouchVector(touchVector)
        let itemIndex: Int? = (itemView != nil) ? itemViews.index(of: itemView!) : nil
        let touchDistance = signedTouchDistanceForTouchVector(touchVector, itemView: itemView)
        
        if fabs(touchDistance) <= maximumTouchDistance {
            centerView?.center = CGPoint(x: touchCenter.x + touchVector.x, y: touchCenter.y + touchVector.y)
            setCenterViewHighlighted(true)
        } else {
            setCenterViewHighlighted(false)
            
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.35,
                           initialSpringVelocity: 7.5,
                           options: [.beginFromCurrentState],
                           animations: { self.centerView?.center = self.touchCenter },
                           completion: nil)
        }
        
        if touchDistance > radius + maximumTouchDistance {
            if let itemView = itemView {
                itemView.setHighlighted(false, animated: true)
                update(itemView: itemView, touchDistance: 0, animated: true)
            }
            selectedItemIndex = nil
            return
        }
        
        if itemIndex != selectedItemIndex {
            if let selectedItemIndex = selectedItemIndex {
                let selectedItemView = itemViews[selectedItemIndex]
                selectedItemView.setHighlighted(false, animated: true)
                update(itemView: selectedItemView, touchDistance: 0, animated: true)
            }
            if let itemView = itemView {
                update(itemView: itemView, touchDistance: touchDistance, animated: true)
                bringSubview(toFront: itemView)
            }
        } else {
            if let itemView = itemView {
                update(itemView: itemView, touchDistance: touchDistance, animated: false)
            }
        }
        
        if let itemView = itemView, fabs(touchDistance) > maximumTouchDistance {
            itemView.setHighlighted(true, animated: true)
        }

        selectedItemIndex = itemIndex
    }
}
