import Foundation
import CoreData
import CoreLocation

/// Represents each individual activity performed by the app user.
class TimeSlot
{
    // MARK: Properties
    let startTime : Date
    let location : CLLocation?
    
    var smartGuessId : Int?
    var endTime : Date? = nil
    var category = Category.unknown
    var categoryWasSetByUser : Bool
    var shouldDisplayCategoryName = true
    
    // MARK: Initializers
    init(withStartTime time: Date, categoryWasSetByUser: Bool)
    {
        self.location = nil
        self.startTime = time
        self.categoryWasSetByUser = categoryWasSetByUser
    }
    
    init(withStartTime time: Date, category: Category, categoryWasSetByUser: Bool)
    {
        self.location = nil
        self.startTime = time
        self.category = category
        self.categoryWasSetByUser = categoryWasSetByUser
    }
    
    init(withStartTime time: Date, category: Category, location: CLLocation?, categoryWasSetByUser: Bool)
    {
        self.startTime = time
        self.location = location
        self.category = category
        self.categoryWasSetByUser = categoryWasSetByUser
    }
    
    init(withStartTime time: Date, endTime: Date?, category: Category, categoryWasSetByUser: Bool)
    {
        self.location = nil
        self.startTime = time
        self.endTime = endTime
        self.category = category
        self.categoryWasSetByUser = categoryWasSetByUser
    }
    
    init(withStartTime time: Date, smartGuess: SmartGuess, location: CLLocation?)
    {
        self.startTime = time
        self.location = location
        self.categoryWasSetByUser = false
        self.smartGuessId = smartGuess.id
        self.category = smartGuess.category
    }
    
    init(withStartTime startTime: Date, endTime: Date?, category: Category, location: CLLocation?, categoryWasSetByUser: Bool)
    {
        self.endTime = endTime
        self.category = category
        self.location = location
        self.startTime = startTime
        self.categoryWasSetByUser = categoryWasSetByUser
    }
}
