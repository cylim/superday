import UIKit

class TimelineHeaderView : UIView
{
    init(date: NSDate)
    {
        let frameHeight = CGFloat(100)
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: frameHeight))
        
        let dayOfWeekFormatter = NSDateFormatter()
        dayOfWeekFormatter.timeZone = NSTimeZone.localTimeZone();
        dayOfWeekFormatter.dateFormat = "EEEE";
        
        let dayOfWeekLabel = UILabel(frame: CGRect(x: 0, y: frameHeight * 0.20, width: self.frame.width, height: frameHeight * 0.50))
        dayOfWeekLabel.textAlignment = NSTextAlignment.Center
        dayOfWeekLabel.font = dayOfWeekLabel.font.fontWithSize(28)
        dayOfWeekLabel.text = dayOfWeekFormatter.stringFromDate(date)
        
        addSubview(dayOfWeekLabel)
        
        let dayOfMonthFormatter = NSDateFormatter();
        dayOfMonthFormatter.timeZone = NSTimeZone.localTimeZone();
        dayOfMonthFormatter.dateFormat = "dd MMMM";
        
        let dayOfMonthLabel = UILabel(frame: CGRect(x: 0, y: frameHeight * 0.50, width: self.frame.width, height: frameHeight * 0.50))
        dayOfMonthLabel.textAlignment = NSTextAlignment.Center
        dayOfMonthLabel.text = dayOfMonthFormatter.stringFromDate(date)
        
        addSubview(dayOfMonthLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}

