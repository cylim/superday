import Foundation
import RxSwift

class MainViewModel
{
    // MARK: Fields
    private let superday = "Superday"
    private let superyesterday = "Superyesterday"
    
    // MARK: Properties
    var date = NSDate()
    
    var title : String
    {
        let today = NSDate().ignoreTimeComponents()
        let yesterday = today.addDays(-1).ignoreTimeComponents()
        
        if date.ignoreTimeComponents().isEqualToDate(today)
        {
            return superday.translate()
        }
        else if date.ignoreTimeComponents().isEqualToDate(yesterday)
        {
            return superyesterday.translate()
        }
        
        let dayOfMonthFormatter = NSDateFormatter();
        dayOfMonthFormatter.timeZone = NSTimeZone.localTimeZone();
        dayOfMonthFormatter.dateFormat = "dd MMMM";
        
        return dayOfMonthFormatter.stringFromDate(date)
    }
}