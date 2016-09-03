import UIKit

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int)
    {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }
    
    convenience init(hexString: String)
    {
        let hex = hexString.hasPrefix("#") ? hexString.substringFromIndex(hexString.startIndex.advancedBy(1)) : hexString
        var hexInt : UInt32 = 0
        NSScanner(string: hex).scanHexInt(&hexInt)
    
        self.init(hex: Int(hexInt))
    }
}