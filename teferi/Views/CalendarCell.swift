import UIKit
import JTAppleCalendar

class CalendarCell : JTAppleDayCellView
{
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var activityView : CalendarDailyActivityView!
    
    private let fontSize = CGFloat(14.0)
    
    func reset(allowScrollingToDate: Bool)
    {
        self.clipsToBounds = true
        self.layer.cornerRadius = 0
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = allowScrollingToDate
        
        self.dateLabel.text = ""
        self.dateLabel.textColor = UIColor.black
        self.dateLabel.font = UIFont.systemFont(ofSize: fontSize)
        
        self.activityView.reset()
    }
    
    func bind(toDate date: Date, isSelected: Bool, allowsScrollingToDate: Bool, dailyActivity: [Activity]?)
    {
        self.reset(allowScrollingToDate: allowsScrollingToDate)
        
        self.dateLabel.text = String(date.day)
        
        self.activityView.update(dailyActivity: dailyActivity)
        
        self.dateLabel.textColor = UIColor.black
        
        if isSelected
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = 14
            self.backgroundColor = Color.lightGreyColor
            self.dateLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
}
