import Foundation
import UIKit

extension String
{
    func translate() -> String
    {
        return NSBundle.mainBundle().localizedStringForKey(self, value: nil, table: nil)
    }
    
    func getBoldStringWithNonBoldText(nonBoldTextRange: NSRange) -> NSAttributedString
    {
        let fontSize = UIFont.systemFontSize()
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize),
            NSForegroundColorAttributeName: UIColor.blackColor()
        ]
        
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.systemFontOfSize(fontSize),
        ]
        
        let attrStr = NSMutableAttributedString(string: self, attributes: attrs)
        attrStr.setAttributes(nonBoldAttribute, range: nonBoldTextRange)
        
        return attrStr
    }
}