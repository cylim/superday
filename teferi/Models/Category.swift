import UIKit

class AssetInfo
{
    let medium : String
    
    var big : String
    {
        return "\(self.medium)Big"
    }
    
    var small : String
    {
        return "\(self.medium)Small"
    }
    
    init(assetName: String)
    {
        self.medium = assetName
    }
}

enum Category : String
{
    case Friends
    case Work
    case Leisure
    case Commute
    case Food
    case Unknown
    
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
