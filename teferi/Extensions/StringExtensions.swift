import Foundation
import UIKit

extension String
{
    func translate() -> String
    {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
    
    func getBoldStringWithNonBoldText(_ nonBoldTextRange: NSRange) -> NSAttributedString
    {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
        ]
        
        let attrStr = NSMutableAttributedString(string: self, attributes: attrs)
        attrStr.setAttributes(nonBoldAttribute, range: nonBoldTextRange)
        
        return attrStr
    }
}
