class Predicate
{
    let format : String
    let parameters : [ AnyObject ]
    
    init(format: String, parameters: [ AnyObject ])
    {
        self.format = format
        self.parameters = parameters
    }
}
