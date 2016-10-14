import UIKit

extension UIColor
{
    //MARK: Initializers
    convenience init(r: Int, g: Int, b: Int, a : CGFloat = 1.0)
    {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init(hex: Int)
    {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff)
    }
    
    convenience init(hexString: String)
    {
        let hex = hexString.hasPrefix("#") ? hexString.substring(from: hexString.characters.index(hexString.startIndex, offsetBy: 1)) : hexString
        var hexInt : UInt32 = 0
        Scanner(string: hex).scanHexInt32(&hexInt)
        
        self.init(hex: Int(hexInt))
    }
    
    @nonobjc static let white = UIColor(r: 255, g: 255, b: 255)
    @nonobjc static let green = UIColor(r: 40, g: 201, b: 128)
    @nonobjc static let purple = UIColor(r: 186, g: 94, b: 255)
    @nonobjc static let yellow = UIColor(r: 255, g: 195, b: 27)
    @nonobjc static let darkGray = UIColor(r: 94, g: 91, b: 91)
    @nonobjc static let offBlack = UIColor(r: 4, g: 4, b: 6)
    @nonobjc static let lightBlue = UIColor(r: 99, g: 213, b: 238)
    @nonobjc static let red = UIColor(r: 255, g: 100, b: 83)
    @nonobjc static let blue = UIColor(r: 61, g: 130, b: 246)
    @nonobjc static let gray = UIColor(r: 206, g: 205, b: 205)
    
    
    private static let logoTrancparency = CGFloat(0.64)
    @nonobjc static let transparentPurple = purple.withAlphaComponent(logoTrancparency)
    @nonobjc static let transparentYellow = yellow.withAlphaComponent(logoTrancparency)
    @nonobjc static let transparentGreen = green.withAlphaComponent(logoTrancparency)
}
