extension Array
{
    func firstOfType<T>() -> T
    {
        return flatMap { $0 as? T }.first!
    }
    
    func lastOfType<T>() -> T
    {
        return flatMap { $0 as? T }.last!
    }
    
    func groupBy<G>(_ closure: (Element) -> G) -> Dictionary<G, [Element]>
    {
        var result = Dictionary<G, [Element]>()
        
        for element in self
        {
            let index = closure(element)
            
            if var array = result[index]
            {
                array.append(element)
            }
            else
            {
                result[index] = [ element ]
            }
        }
        
        return result
    }
}
