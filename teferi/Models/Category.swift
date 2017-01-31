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
    
    private typealias CategoryData = (description: String, color: UIColor, icon: Asset)
    
    private var attributes : CategoryData
    {
        //This enum ensures we have all categories covered
        switch self
        {
        case .friends:
            return (description: L10n.friends,      color: Color.green,         icon: .icFriends)
        case .work:
            return (description: L10n.work,         color: Color.yellow,        icon: .icWork)
        case .leisure:
            return (description: L10n.leisure,      color: Color.purple,        icon: .icLeisure)
        case .commute:
            return (description: L10n.commute,      color: Color.lightBlue,     icon: .icCommute)
        case .food:
            return (description: L10n.food,         color: Color.red,           icon: .icFood)
        case .unknown:
            return (description: L10n.unknown,      color: Color.gray,          icon: .icCancel)
        }
    }
    
    /// Get all categories
    static let all : [Category] = [.friends, .work, .leisure, .commute, .food, .unknown]
    
    /// Get the Color associated with the category.
    var color : UIColor
    {
        return self.attributes.color
    }
    
    /// Get the Asset for the category.
    var icon : Asset
    {
        return self.attributes.icon
    }
    
    /// Get the Localised name for the category.
    var description : String
    {
        return self.attributes.description
    }
}
