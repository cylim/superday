import Foundation

class Predicate
{
    let format : String
    let parameters : [ AnyObject ]
    
    init(parameter: String, equals object: AnyObject)
    {
        self.format = "\(parameter) == %@"
        self.parameters = [ object ]
    }
    
    init(parameter: String, rangesFromDate initialDate: NSDate, toDate finalDate: NSDate)
    {
        self.format = "(\(parameter) >= %@) AND (\(parameter) <= %@)"
        self.parameters = [ initialDate, finalDate ]
    }
}
