import Foundation
import UIKit
import Darwin

extension String
{
    //MARK: Methods
    
    /**
     Finds the localized string for the provided key in the main bundle and returns it.
     
     - Returns: A localized version of the provided key.
     */
    func translate() -> String
    {
        return NSLocalizedString(self, comment: "")
    }
}
