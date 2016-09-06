import UIKit

class TimelineHeaderView : UIView
{
    init(date: NSDate)
    {
        let topPadding = 5
        let leftPadding = 34
        let pictureSize = 24
        let frameHeight = CGFloat(80)
        let centerY = Int(frameHeight / 2)
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: frameHeight))
        
        let icon = UIImageView(frame: CGRect(x: leftPadding, y: topPadding + centerY - pictureSize / 2, width: 24, height: 24))
        icon.image = UIImage(named: "icSuperday")
        addSubview(icon)
        
        let dayOfMonthLabel = UILabel(frame: CGRect(x: leftPadding + pictureSize + 10, y: topPadding + centerY - 25, width: 200, height: 50))
        dayOfMonthLabel.text = getStringForDay(date)
        addSubview(dayOfMonthLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    private func getStringForDay(date: NSDate) -> String
    {
        let today = NSDate()
        let yesterday = today.addDays(-1)
        
        if date.equalsDate(today)
        {
            return "Superday"
        }
        else if date.equalsDate(yesterday)
        {
            return "Superyesterday"
        }
        else
        {
            let dayOfMonthFormatter = NSDateFormatter();
            dayOfMonthFormatter.timeZone = NSTimeZone.localTimeZone();
            dayOfMonthFormatter.dateFormat = "dd MMMM";
            
            return dayOfMonthFormatter.stringFromDate(date)
        }
    }
}

