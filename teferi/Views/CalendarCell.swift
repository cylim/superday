import UIKit
import JTAppleCalendar

class CalendarCell : JTAppleDayCellView
{
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var activityView : UIView!
    
    private let fontSize = CGFloat(14.0)
    
    func reset(allowScrollingToDate: Bool)
    {
        for subView in self.activityView.subviews { subView.removeFromSuperview() }
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 0
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = allowScrollingToDate
        
        self.dateLabel.text = ""
        self.dateLabel.textColor = UIColor.black
        self.dateLabel.font = UIFont.systemFont(ofSize: fontSize)
        
        self.activityView.clipsToBounds = true
        self.activityView.layer.cornerRadius = 1.0
        self.activityView.backgroundColor = UIColor.white
    }
    
    func bind(toDate date: Date, isSelected: Bool, allowsScrollingToDate: Bool, categorySlots: [CategorySlot]?)
    {
        self.reset(allowScrollingToDate: allowsScrollingToDate)
        
        self.dateLabel.text = String(date.day)
        self.activityView.backgroundColor = Color.lightGreyColor
        
        self.updateActivity(categorySlots: categorySlots!)
        self.dateLabel.textColor = UIColor.black
        
        if isSelected
        {
            self.clipsToBounds = true
            self.layer.cornerRadius = 14
            self.backgroundColor = Color.lightGreyColor
            self.dateLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
    
    // updates Activity based on sorted time slots for the day
    private func updateActivity(categorySlots: [CategorySlot])
    {
        self.activityView.layoutIfNeeded()
        let timeSpent:TimeInterval = categorySlots.reduce(0.0)
        {
            return $0 + $1.duration
        }
        let fullWidth = self.activityView.bounds.size.width - CGFloat(categorySlots.count) + 1.0
        var prev:UIView?
        if categorySlots.count > 0
        {
            self.isUserInteractionEnabled = true
        }
        for categorySlot in categorySlots
        {
            let timeSlotView = UIView()
            timeSlotView.clipsToBounds = true
            timeSlotView.layer.cornerRadius = 1
            timeSlotView.backgroundColor = categorySlot.category.color
            let timeSlotWidth = Double(fullWidth) * (categorySlot.duration / timeSpent)
            self.activityView.addSubview(timeSlotView)
            timeSlotView.snp.makeConstraints({ (make) in
                make.top.equalTo(self.activityView.snp.top)
                make.bottom.equalTo(self.activityView.snp.bottom)
                if let previous = prev
                {
                    make.left.equalTo(previous.snp.right).offset(1)
                } else
                {
                    make.left.equalTo(self.activityView.snp.left)
                }
                
                // category can occur only once
                if categorySlot.category != categorySlots.last?.category
                {
                    make.width.equalTo(timeSlotWidth)
                }
            })
            prev = timeSlotView
        }
        // last time slot is rounded to fit the end
        if let lastTimeSlot = prev
        {
            lastTimeSlot.snp.makeConstraints(
                {(make) in
                    make.right.equalTo(self.activityView.snp.right)
            })
            self.activityView.backgroundColor = UIColor.clear
        }
        self.activityView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
}
