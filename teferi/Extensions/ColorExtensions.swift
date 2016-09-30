import UIKit

extension UIColor
{
    //MARK: Initializers
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
        let hex = hexString.hasPrefix("#") ? hexString.substring(from: hexString.characters.index(hexString.startIndex, offsetBy: 1)) : hexString
        var hexInt : UInt32 = 0
        Scanner(string: hex).scanHexInt32(&hexInt)
    
        self.init(hex: Int(hexInt))
    }
    
    @nonobjc static let white = UIColor(red: 255, green: 255, blue: 255)
    @nonobjc static let green = UIColor(red: 40, green: 201, blue: 128)
    @nonobjc static let purple = UIColor(red: 186, green: 94, blue: 255)
    @nonobjc static let yellow = UIColor(red: 255, green: 195, blue: 27)
    @nonobjc static let darkGray = UIColor(red: 94, green: 91, blue: 91)
    @nonobjc static let offBlack = UIColor(red: 4, green: 4, blue: 6)
    @nonobjc static let lightBlue = UIColor(red: 99, green: 213, blue: 238)
    @nonobjc static let red = UIColor(red: 255, green: 100, blue: 83)
    @nonobjc static let blue = UIColor(red: 61, green: 130, blue: 246)
    @nonobjc static let gray = UIColor(red: 206, green: 205, blue: 205)
    
    private static let logoTrancparency = CGFloat(0.64)
    @nonobjc static let transparentPurple = purple.withAlphaComponent(logoTrancparency)
    @nonobjc static let transparentYellow = yellow.withAlphaComponent(logoTrancparency)
    @nonobjc static let transparentGreen = green.withAlphaComponent(logoTrancparency)
}
