import UIKit

/**
 Represents the possible categories for any given TimeSlot.
 
 - Friends: For activities with your friends.
 - Work: For any work-related activities.
 - Leisure: For recreation activities.
 - Commute: Used when the app detects the user is traveling.
 - Food: For any work-related activities.
 - Unknown: For app-created activities that are yet to be defined by the user.
 */
enum Category : String
{
    case friends
    case work
    case leisure
    case commute
    case food
    case unknown
    
    //MARK: Properties
    
    /// Get the color associated with the category.
    var color : UIColor
    {
        switch(self)
        {
        case .friends:
            return UIColor(hexString: "#28C980")
        case .work:
            return UIColor(hexString: "#FFC31B")
        case .leisure:
            return UIColor(hexString: "#BA5EFF")
        case .commute:
            return UIColor(hexString: "#63D5EE")
        case .food:
            return UIColor(hexString: "#FF6453")
        case .unknown:
            return UIColor(hexString: "#CECDCD")
        }
    }
    
    /// Get the AssetInfo for the category.
    var icon : String
    {
        switch(self)
        {
        case .friends:
            return "icFriends"
        case .work:
            return "icWork"
        case .leisure:
            return "icLeisure"
        case .commute:
            return "icCommute"
        case .food:
            return "icFood"
        case .unknown:
            return "icCancel"
        }
    }
}
