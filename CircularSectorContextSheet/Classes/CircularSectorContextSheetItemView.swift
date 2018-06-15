import Foundation
import UIKit

class CircularSectorContextSheetItemView: UIView {
    var image: UIImage? {
        get { return imageView?.image }
        set { imageView?.image = newValue }
    }
    var highlightedImage: UIImage? {
        get { return highlightedImageView?.image }
        set { highlightedImageView?.image = newValue }
    }
    var title: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue }
    }
    var isHighlighted: Bool = false
    let textPadding: CGFloat = 5
    
    weak var imageView: UIImageView?
    weak var highlightedImageView: UIImageView?
    weak var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        imageView = {
            let imageView = UIImageView()
            addSubview(imageView)
            return imageView
        }()
        
        highlightedImageView = {
            let imageView = UIImageView()
            addSubview(imageView)
            return imageView
        }()
        
        titleLabel = {
            let label = UILabel()
            label.clipsToBounds = true
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            label.layer.cornerRadius = 7
            label.backgroundColor = UIColor(white: 0, alpha: 0.4)
            label.textColor = .white
            label.alpha = 0
            addSubview(label)
            return label
        }()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageRect = CGRect(x: 0, y: (frame.height - frame.width) / 2, width: frame.width, height: frame.width)
        imageView?.frame = imageRect
        highlightedImageView?.frame = imageRect
        if let titleLabel = titleLabel, let title = title {
            let labelWidth = 2 * textPadding + ceil((title as NSString).size(withAttributes: [.font : titleLabel.font]).width)
            titleLabel.frame = CGRect(x: (frame.width - labelWidth) / 2, y: 0, width: labelWidth, height: 14)
        }
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        isHighlighted = highlighted
        
        let animations = {
            self.imageView?.alpha = (highlighted ? 0.0 : 1.0)
            self.highlightedImageView?.alpha = (highlighted ? 1.0 : 0.0)
            self.titleLabel?.alpha = (highlighted ? 1.0 : 0.0)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: animations, completion: nil)
        } else {
            animations()
        }
    }
}
