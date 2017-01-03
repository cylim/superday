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
    
    func groupBy<G: Hashable>(_ closure: (Element) -> G) -> [[Element]]
    {
        var groups = [[Element]]()
        
        for element in self
        {
            let key = closure(element)
            var active = Int()
            var isNewGroup = true
            var array = [Element]()
            
            for (index, group) in groups.enumerated()
            {
                let firstKey = closure(group[0])
                if firstKey == key
                {
                    array = group
                    active = index
                    isNewGroup = false
                    break
                }
            }
            
            array.append(element)
            
            if isNewGroup
            {
                groups.append(array)
            }
            else
            {
                groups.remove(at: active)
                groups.insert(array, at: active)
            }
        }
        
        return groups
    }
}
