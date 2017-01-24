import UIKit

class EmptyStateView : UITableViewCell
{
    @IBOutlet private weak var workImage : UIImageView!
    @IBOutlet private weak var leisureImage : UIImageView!
    @IBOutlet private weak var commuteImage : UIImageView!
    @IBOutlet private weak var friendsImage : UIImageView!
    
    private let rotationAngles = [ 17.0, -18.0, 0.0, -10.0 ]
    private let categories : [Category] = [ .work, .leisure, .commute, .friends ]
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        for (index, imageView) in [ workImage!, leisureImage!, commuteImage!, friendsImage! ].enumerated()
        {
            let category = self.categories[index]
            let rotationAngle = self.rotationAngles[index]
            
            let image = UIImage(asset: category.icon)!.withRenderingMode(.alwaysTemplate)
            
            imageView.image = image
            imageView.tintColor = category.color
            imageView.contentMode = .scaleAspectFill
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle * (Double.pi / 180.0)))
        }
    }
}
