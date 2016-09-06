import UIKit

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
        case Friends:
            return UIColor(hexString: "#28C980")
        case Work:
            return UIColor(hexString: "#FFC31B")
        case Leisure:
            return UIColor(hexString: "#BA5EFF")
        case Commute:
            return UIColor(hexString: "#63D5EE")
        case Food:
            return UIColor(hexString: "#FF6453")
        case Unknown:
            return UIColor(hexString: "#CECDCD")
        }
    }
    
    var imageAssetName : String
    {
        switch(self)
        {
        case Friends:
            return "icFriendsGreen"
        case Work:
            return "icWorkYellow"
        case Leisure:
            return "icLeisurePurple"
        case Commute:
            return "icCommuteBlue"
        case Food:
            return "icFoodRed"
        case Unknown:
            return "icCancelGrey"
        }
    }
}