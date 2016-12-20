import Foundation
import UIKit

class CalendarDailyActivityView : UIView
{
    func reset()
    {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 1.0
        self.backgroundColor = UIColor.white
    }
    
    func updateActivity(dailyActivity: [ CategoryDuration ]?)
    {
        self.reset()
        
        guard let categorySlots = dailyActivity else
        {
            self.backgroundColor = Color.lightGreyColor
            return
        }
        
        self.backgroundColor = UIColor.clear
        
        //self.activityView.layoutIfNeeded()
        let totalTimeSpent = categorySlots.reduce(0.0, self.sumDuration)
        let availableWidth = Double(self.bounds.size.width - CGFloat(categorySlots.count) + 1.0)
        
        var startingX = 0.0
        
        
        
        for categorySlot in categorySlots
        {
            let layerWidth = availableWidth * (categorySlot.duration / totalTimeSpent)
            
            //Filters layers too small to be seen
            guard layerWidth > 1 else { continue }
            
            let layer = CALayer()
            layer.cornerRadius = 1
            layer.backgroundColor = categorySlot.category.color.cgColor
            layer.frame = CGRect(x: startingX, y: 0, width: layerWidth, height: Double(self.frame.height))
            startingX += layerWidth + 1
            
            self.layer.addSublayer(layer)
        }
        
        self.layoutIfNeeded()
    }
    
    private func sumDuration(accumulator: Double, dailyActivity: CategoryDuration) -> TimeInterval
    {
        return accumulator + dailyActivity.duration
    }
}
