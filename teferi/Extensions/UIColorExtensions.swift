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
    
    var hexString : String
    {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
