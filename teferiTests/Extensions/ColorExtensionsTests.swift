import UIKit
import XCTest
import CoreGraphics
import Nimble
@testable import teferi

class UIColorExtensionsTests : XCTestCase
{
    func testInitFromHexStringWorksWithAPrefixHash()
    {
        let hexString = "#FFFF00"
        let color = UIColor(hexString: hexString)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(1.0))
        expect(blue).to(equal(0))
    }
    
    func testInitFromHexStringWorksWithoutAPrefixHash()
    {
        let hexString = "FF0000"
        let color = UIColor(hexString: hexString)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(0))
        expect(blue).to(equal(0))
    }
    
    func testInitFromHexWorksWithAHexLiteral()
    {
        let hex = 0xFF00FF
        let color = UIColor(hex: hex)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(0))
        expect(blue).to(equal(1.0))
    }
    
    func testInitFromIntWorksWithIntegerRepresentationsOfHexValues()
    {
        let color = UIColor(r: 255, g: 0, b: 0)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(0))
        expect(blue).to(equal(0))
    }
    
    func testGetHexValueOfColor()
    {
        let color = UIColor(r: 255, g: 0, b: 42)
        let hex = color.hexString.uppercased()
        
        expect(hex).to(equal("#FF002A"))
    }
}
