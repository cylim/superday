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
    case Friends
    case Work
    case Leisure
    case Commute
    case Food
    case Unknown
    
    //MARK: Properties
    
    /// Get the color associated with the category.
    var color : UIColor
    {
        switch(self)
        {
        case .Friends:
            return UIColor(hexString: "#28C980")
        case .Work:
            return UIColor(hexString: "#FFC31B")
        case .Leisure:
            return UIColor(hexString: "#BA5EFF")
        case .Commute:
            return UIColor(hexString: "#63D5EE")
        case .Food:
            return UIColor(hexString: "#FF6453")
        case .Unknown:
            return UIColor(hexString: "#CECDCD")
        }
    }
    
    /// Get the AssetInfo for the category.
    var assetInfo : AssetInfo
    {
        switch(self)
        {
        case .Friends:
            return AssetInfo(assetName: "icFriends")
        case .Work:
            return AssetInfo(assetName: "icWork")
        case .Leisure:
            return AssetInfo(assetName: "icLeisure")
        case .Commute:
            return AssetInfo(assetName: "icCommute")
        case .Food:
            return AssetInfo(assetName: "icFood")
        case .Unknown:
            return AssetInfo(assetName: "icCancel")
        }
    }
}

class AssetInfo
{
    //MARK: Properties
    let medium : String
    
    var big : String
    {
        return "\(self.medium)Big"
    }
    
    var small : String
    {
        return "\(self.medium)Small"
    }
    
    //MARK: Initializers
    init(assetName: String)
    {
        self.medium = assetName
    }
}

