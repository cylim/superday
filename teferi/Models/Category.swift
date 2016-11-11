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
    case commute
    case food
    case friends
    case work
    case leisure
    case unknown
    
    //MARK: Properties
    
    /// Get the color associated with the category.
    var color : UIColor
    {
        return UIColor(hexString: self.colorHex)
    }
    
    /// Get the color associated with the category.
    var colorHex : String
    {
        switch(self)
        {
        case .friends:
            return "#28C980"
        case .work:
            return "#FFC31B"
        case .leisure:
            return "#BA5EFF"
        case .commute:
            return "#63D5EE"
        case .food:
            return "#FF6453"
        case .unknown:
            return "#CECDCD"
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
