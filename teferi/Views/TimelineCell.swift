import UIKit

///Cell that represents a TimeSlot in the timeline
class TimelineCell : UITableViewCell
{
    // MARK: Fields
    private let hourMask = "%02d h %02d min"
    private let minuteMask = "%02d min"
    private lazy var lineHeightConstraint : NSLayoutConstraint =
    {
        return NSLayoutConstraint(item: self.lineView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(Constants.minLineSize))
    }()
    
    //MARK: Outlets
    @IBOutlet weak private var categoryIcon : UIImageView?
    @IBOutlet weak private var slotDescription : UILabel?
    @IBOutlet weak private var elapsedTime : UILabel?
    @IBOutlet weak private var lineView : UIView?
    
    // MARK: Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        lineView?.addConstraint(lineHeightConstraint)
    }
    
    /**
     Binds the current TimeSlot in order to change the UI accordingly.
     
     - Parameter timeSlot: TimeSlot that will be bound.
     */
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
        let newHeight = CGFloat(Constants.minLineSize * (1 + (minutes / 15) + (hours * 4)))
        lineHeightConstraint.constant = newHeight
        
        lineView?.backgroundColor = categoryColor
        lineView?.layoutIfNeeded()
    }
}
