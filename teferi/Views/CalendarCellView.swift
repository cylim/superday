import UIKit
import JTAppleCalendar

class CalendarCellView: JTAppleDayCellView
{

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    
    func updateCell(cellState: CellState, startDate: Date, date: Date, selectedDate: Date, timeSlots: [TimeSlot])
    {
        self.resetCell()
        if cellState.dateBelongsTo == .thisMonth
        {
            self.dateLabel.text = cellState.text
            if Calendar.current.compare(date,
                                           to: startDate,
                                           toGranularity: .day) == .orderedAscending
            {// is smaller
                self.activityView.backgroundColor = Color.lightGreyColor
            } else
            {
                self.activityView.backgroundColor = Color.lightGreyColor
                self.updateActivity(timeSlots: timeSlots)
                self.dateLabel.textColor = UIColor.black
            }
        }
        if Calendar.current.isDate(date, inSameDayAs: selectedDate)
        {//is the same
            if cellState.dateBelongsTo == .thisMonth
            {
                self.updateForCurrentDay()
            }
        }
    }

    //updates Activity based on sorted time slots for the day
    func updateActivity(timeSlots: [TimeSlot])
    {
        self.activityView.layoutIfNeeded()
        let activeTimeSlots = timeSlots.filter {
            $0.category != .unknown
        }
        let timeSpent:TimeInterval = activeTimeSlots.reduce(0.0) {
            return $0 + $1.duration
        }
        let fullWidth = self.activityView.bounds.size.width
        var prev:UIView?
        if activeTimeSlots.count > 0 {
            self.isUserInteractionEnabled = true
        }
        for timeSlot in activeTimeSlots
        {
        
            let timeSlotView = UIView()
            timeSlotView.backgroundColor = timeSlot.category.color
            let timeSlotWidth = Double(fullWidth) * (timeSlot.duration / timeSpent)
            self.activityView.addSubview(timeSlotView)
            timeSlotView.snp.makeConstraints({ (make) in
                make.top.equalTo(self.activityView.snp.top)
                make.bottom.equalTo(self.activityView.snp.bottom)
                if let previous = prev
                {
                    make.left.equalTo(previous.snp.right)
                } else
                {
                    make.left.equalTo(self.activityView.snp.left)
                }
                
                if timeSlot != activeTimeSlots.last
                {
                    make.width.equalTo(timeSlotWidth)
                }
                
            })
            prev = timeSlotView
        }
        // last time slot is rounded
        if let lastTimeSlot = prev
        {
            lastTimeSlot.snp.makeConstraints(
            {(make) in
                make.right.equalTo(self.activityView.snp.right)
            })
        }
        self.activityView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    func updateForCurrentDay()
    {
        self.backgroundColor = Color.lightGreyColor
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.dateLabel.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    func resetCell()
    {
        for subView in self.activityView.subviews
        {
            subView.removeFromSuperview()
        }
        self.dateLabel.text = ""
        self.dateLabel.textColor = UIColor.black
        self.backgroundColor = UIColor.white
        self.activityView.backgroundColor = UIColor.white
        self.layer.cornerRadius = 0
        self.clipsToBounds = true
        self.dateLabel.font = UIFont.systemFont(ofSize: 14)
        self.isUserInteractionEnabled = false
    }
}
