import UIKit
import CircularSectorContextSheet

final class ViewController: UIViewController, CircularSectorContextSheetDelegate {
    
    var contextSheet: CircularSectorContextSheet?
    let contextSheetItems = [CircularSectorContextSheetItem(identifier: "one", title: "One", image: UIImage(named: "share"), highlightedImage: UIImage(named: "share_b")),
                             CircularSectorContextSheetItem(identifier: "two", title: "Two", image: UIImage(named: "share"), highlightedImage: UIImage(named: "share_b")),
                             CircularSectorContextSheetItem(identifier: "three", title: "Three", image: UIImage(named: "share"), highlightedImage: UIImage(named: "share_b")),
                             CircularSectorContextSheetItem(identifier: "four", title: "Four", image: UIImage(named: "share"), highlightedImage: UIImage(named: "share_b")),
                             CircularSectorContextSheetItem(identifier: "five", title: "Five", image: UIImage(named: "share"), highlightedImage: UIImage(named: "share_b"))]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contextSheet = CircularSectorContextSheet(items: Array(contextSheetItems[..<3]))
        contextSheet?.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        view.addGestureRecognizer(longPress)
    }

    @IBAction func one(_ sender: Any) {
        contextSheet?.removeFromSuperview()
        contextSheet = CircularSectorContextSheet(items: Array(contextSheetItems[..<1]))
        contextSheet?.delegate = self
    }
    
    @IBAction func two(_ sender: Any) {
        contextSheet?.removeFromSuperview()
        contextSheet = CircularSectorContextSheet(items: Array(contextSheetItems[..<2]))
        contextSheet?.delegate = self
    }
    
    @IBAction func three(_ sender: Any) {
        contextSheet?.removeFromSuperview()
        contextSheet = CircularSectorContextSheet(items: Array(contextSheetItems[..<3]))
        contextSheet?.delegate = self
    }
    
    @IBAction func four(_ sender: Any) {
        contextSheet?.removeFromSuperview()
        contextSheet = CircularSectorContextSheet(items: Array(contextSheetItems[..<4]))
        contextSheet?.delegate = self
    }

    @IBAction func five(_ sender: Any) {
        contextSheet?.removeFromSuperview()
        contextSheet = CircularSectorContextSheet(items: Array(contextSheetItems[..<5]))
        contextSheet?.delegate = self
        contextSheet?.maximumAngle = .pi * 0.8
    }
    
    @objc func longPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            contextSheet?.start(gestureRecognizer: gestureRecognizer, in: view)
        }
    }


    // MARK: ContextSheetDelegate
    func contextSheet(_ contextSheet: CircularSectorContextSheet, didSelect item: CircularSectorContextSheetItem.Identifier, userInfo: [String: Any]?) {
        switch item {
        case "one":
            print("Selected 1")
        case "two":
            print("Selected 2")
        case "three":
            print("Selected 3")
        case "four":
            print("Selected 4")
        case "five":
            print("Selected 5")
        default:
            break
        }
    }
}

