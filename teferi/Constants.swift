import CoreGraphics

///Contains the app's constants.
class Constants
{
    ///All possible categories
    static let categories =  [ Category.friends, Category.work, Category.leisure, Category.commute, Category.food, Category.unknown ]
    
    ///Distance the user has to travel in order to trigger a new location event.
    static let distanceFilter = 100.0
    
    ///Minimum size of the cosmetic line that appears on a TimeSlot cell.
    static let minLineSize = 12
    
    ///Key used for the preference that indicates whether the user is currently traveling or not.
    static let isTravelingKey = "isTravelingKey"
    
    ///Name of the file that stores information regarding the first location detected since the user's last travel.
    static let firstLocationFile = "firstLocationFile"
    
    ///Alpha of views when the user is editing a TimeSlot
    static let editingAlpha = CGFloat(0.4)
}
