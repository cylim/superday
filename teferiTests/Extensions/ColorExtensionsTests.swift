import UIKit
import XCTest
import Nimble
import CoreGraphics
@testable import teferi

class UIColorExtensionsTests : XCTestCase
{
    func testInitFromHexStringWorksWithAPrefixHash()
    {
        let hexString = "#FFFF00"
        let color = UIColor(hexString: hexString)
        
        let components = CGColorGetComponents(color.cgColor)
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(1.0))
        expect(blue).to(equal(0))
    }
    
    func testInitFromHexStringWorksWithoutAPrefixHash()
    {
        let hexString = "FF0000"
        let color = UIColor(hexString: hexString)
        
        let components = CGColorGetComponents(color.cgColor)
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(0))
        expect(blue).to(equal(0))
    }
    
    func testInitFromHexWorksWithAHexLiteral()
    {
        let hex = 0xFF00FF
        let color = UIColor(hex: hex)
        
        let components = CGColorGetComponents(color.cgColor)
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        expect(red).to(equal(1.0))
        expect(green).to(equal(0))
        expect(blue).to(equal(1.0))
    }
    
    func testInitFromIntWorksWithIntegerRepresentationsOfHexValues()
    {
        let color = UIColor(red: 255, green: 128, blue: 0)
        
        let components = CGColorGetComponents(color.cgColor)
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        expect(red).to(equal(1.0))
        expect(green).to(beCloseTo(0.5, within: 0.02))
        expect(blue).to(equal(0))
    }
}
