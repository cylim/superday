import UIKit

class TimelineCell : UITableViewCell
{
    // MARK: Static properties
    static let minLineSize = 12
    
    // MARK: Fields
    fileprivate lazy var lineHeightConstraint : NSLayoutConstraint =
    {
        return NSLayoutConstraint(item: self.lineView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(TimelineCell.minLineSize))
    }()
    
    fileprivate let hourMask = "%02d h %02d min"
    fileprivate let minuteMask = "%02d min"
    
    @IBOutlet weak fileprivate var categoryIcon : UIImageView?
    @IBOutlet weak fileprivate var slotDescription : UILabel?
    @IBOutlet weak fileprivate var elapsedTime : UILabel?
    @IBOutlet weak fileprivate var lineView : UIView?
    
    // MARK: Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        lineView?.addConstraint(lineHeightConstraint)
    }
    
    func bindTimeSlot(_ timeSlot: TimeSlot)
    {
        let categoryColor = timeSlot.category.color
        
        //Icon that indicates the slot's category
        categoryIcon?.image = UIImage(named: timeSlot.category.assetInfo.small)
        
        //Description and starting time of the slot
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: timeSlot.startTime as Date)
        let categoryText = timeSlot.category == .Unknown ? "" : String(describing: timeSlot.category)
        
        let description = "\(categoryText) \(dateString)"
        let nonBoldRange = NSMakeRange(categoryText.characters.count, dateString.characters.count)
        let attributedText = description.getBoldStringWithNonBoldText(nonBoldRange)

        slotDescription?.attributedText = attributedText
        
        //Label that shows how long the slot lasted
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        elapsedTime?.textColor = categoryColor
        elapsedTime?.text = hours > 0 ? String(format: hourMask, hours, minutes) : String(format: minuteMask, minutes)
        
        //Cosmetic line®
        let newHeight = CGFloat(TimelineCell.minLineSize * (1 + (minutes / 15) + (hours * 4)))
        lineHeightConstraint.constant = newHeight
        
        lineView?.backgroundColor = categoryColor
        lineView?.layoutIfNeeded()
    }
}
