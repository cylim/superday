import UIKit
import XCTest
import CoreGraphics
@testable import teferi

class UIColorExtensionsTests : XCTestCase
{
    func testInitFromHexStringWorksWithAPrefixHash()
    {
        let hexString = "#FFFF00"
        let color = UIColor(hexString: hexString)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0)
        XCTAssertEqual(green, 1.0)
        XCTAssertEqual(blue, 0)
    }
    
    func testInitFromHexStringWorksWithoutAPrefixHash()
    {
        let hexString = "FF0000"
        let color = UIColor(hexString: hexString)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0)
        XCTAssertEqual(green, 0)
        XCTAssertEqual(blue, 0)
    }
    
    func testInitFromHexWorksWithAHexLiteral()
    {
        let hex = 0xFF00FF
        let color = UIColor(hex: hex)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0)
        XCTAssertEqual(green, 0)
        XCTAssertEqual(blue, 1.0)
    }
    
    func testInitFromIntWorksWithIntegerRepresentationsOfHexValues()
    {
        let color = UIColor(r: 255, g: 0, b: 0)
        
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha : CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0)
        XCTAssertEqual(green, 0)
        XCTAssertEqual(blue, 0)
    }
}
