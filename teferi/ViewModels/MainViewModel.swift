import Foundation
import RxSwift

class MainViewModel
{
    // MARK: Fields
    fileprivate let superday = "Superday"
    fileprivate let superyesterday = "Superyesterday"
    
    // MARK: Properties
    var date = Date()
    
    var title : String
    {
        let today = Date().ignoreTimeComponents()
        let yesterday = today.addDays(-1).ignoreTimeComponents()
        
        if date.ignoreTimeComponents() == today
        {
            return superday.translate()
        }
        else if date.ignoreTimeComponents() == yesterday
        {
            return superyesterday.translate()
        }
        
        let dayOfMonthFormatter = DateFormatter();
        dayOfMonthFormatter.timeZone = TimeZone.autoupdatingCurrent;
        dayOfMonthFormatter.dateFormat = "dd MMMM";
        
        return dayOfMonthFormatter.string(from: date)
    }
}
