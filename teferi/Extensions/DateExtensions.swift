import Foundation

extension Date
{
    func addDays(_ daysToAdd: Int) -> Date
    {
        var dayComponent = DateComponents()
        dayComponent.day = daysToAdd
        
        let calendar = Calendar.current;
        let nextDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: self, options: NSCalendar.Options())!
        return nextDate
    }
    
    func ignoreTimeComponents() -> Date
    {
        let units : NSCalendar.Unit = [ .year, .month, .day];
        let calendar = Calendar.current;
        return calendar.date(from: (calendar as NSCalendar).components(units, from: self))!
    }
}
