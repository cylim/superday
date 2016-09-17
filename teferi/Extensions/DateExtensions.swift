import Foundation

extension Date
{
    var yesterday : Date
    {
        return self.add(days: -1)
    }
    
    var tomorrow : Date
    {
        return self.add(days: 1)
    }
    
    func add(days daysToAdd: Int) -> Date
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
