import UIKit

class TimelineCell : UITableViewCell
{
    private lazy var lineHeightConstraint : NSLayoutConstraint =
    {
        return NSLayoutConstraint(item: self.lineView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
    }()
    
    private let hourMask = "%02d h %02d min"
    private let minuteMask = "%02d min"
    
    @IBOutlet weak private var categoryIcon : UIImageView?
    @IBOutlet weak private var slotDescription : UILabel?
    @IBOutlet weak private var elapsedTime : UILabel?
    @IBOutlet weak private var lineView : UIView?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        lineView?.addConstraint(lineHeightConstraint)
    }
    
    func bindTimeSlot(timeSlot: TimeSlot)
    {
        let categoryColor = timeSlot.category.color
        
        //Icon that indicates the slot's category
        categoryIcon?.image = UIImage(named: timeSlot.category.imageAssetName)
        
        //Description and starting time of the slot
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        let dateString = formatter.stringFromDate(timeSlot.startTime)
        let categoryText = timeSlot.category == .Unknown ? "" : String(timeSlot.category)
        
        let description = "\(categoryText) \(dateString)"
        let nonBoldRange = NSMakeRange(categoryText.characters.count, dateString.characters.count)
        let attributedText = description.getBoldStringWithNonBoldText(nonBoldRange)

        slotDescription?.attributedText = attributedText
        
        //Label that shows how long the slot lasted
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        let formatMask = hours > 0 ? hourMask : minuteMask
        elapsedTime?.textColor = categoryColor
        elapsedTime?.text = String(format: formatMask, hours, minutes)
        
        //Cosmetic line®
        let newHeight = CGFloat(40 * (hours + 1))
        lineHeightConstraint.constant = newHeight
        
        lineView?.backgroundColor = categoryColor
        lineView?.layoutIfNeeded()
    }
}