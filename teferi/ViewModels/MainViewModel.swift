import Foundation
import RxSwift

///ViewModel for the MainViewController.
class MainViewModel
{
    // MARK: Fields
    private let superday = "Superday"
    private let superyesterday = "Superyesterday"
    
    // MARK: Properties
    var currentDate = Date()
    
    ///Gets the title for the header. Changes on new locations.
    var title : String
    {
        let today = Date().ignoreTimeComponents()
        let yesterday = today.yesterday.ignoreTimeComponents()
        
        if currentDate.ignoreTimeComponents() == today
        {
            return superday.translate()
        }
        else if currentDate.ignoreTimeComponents() == yesterday
        {
            return superyesterday.translate()
        }
        
        let dayOfMonthFormatter = DateFormatter();
        dayOfMonthFormatter.timeZone = TimeZone.autoupdatingCurrent;
        dayOfMonthFormatter.dateFormat = "dd MMMM";
        
        return dayOfMonthFormatter.string(from: currentDate)
    }
}
