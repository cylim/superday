import Foundation

extension NSDate
{
    func addDays(daysToAdd: Int) -> NSDate
    {
        let dayComponent = NSDateComponents()
        dayComponent.day = daysToAdd
        
        let calendar = NSCalendar.currentCalendar();
        let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: self, options: NSCalendarOptions())!
        return nextDate
    }
    
    func ignoreTimeComponents() -> NSDate
    {
        let units : NSCalendarUnit = [ .Year, .Month, .Day];
        let calendar = NSCalendar.currentCalendar();
        return calendar.dateFromComponents(calendar.components(units, fromDate: self))!
    }
}