import UIKit

class TimelineCell : UITableViewCell
{
    private let hourMask = "%02d h %02d min"
    private let minuteMask = "%02d min"
    
    @IBOutlet weak private var categoryIcon : UIImageView?
    @IBOutlet weak private var slotDescription : UILabel?
    @IBOutlet weak private var elapsedTime : UILabel?
    @IBOutlet weak private var line : UIView?
    
    func bindTimeSlot(timeSlot: TimeSlot)
    {
        let categoryColor = timeSlot.category.color
        
        //Icon that indicates the slot's category
        categoryIcon?.backgroundColor = categoryColor
        
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
        elapsedTime?.text = String(format: formatMask, hours, minutes)
        
        //Cosmetic line®
        line?.backgroundColor = categoryColor
    }
}