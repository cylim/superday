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
    
    func groupBy<Key: Hashable>(_ selectKey: (Element) -> Key) -> [[Element]]
    {
        var groups = [Key:[Element]]()
        
        for element in self
        {
            let key = selectKey(element)
            
            if case nil = groups[key]?.append(element)
            {
                groups[key] = [element]
            }
        }
        
        return groups.map { $0.value }
    }
    
    func safeGetElement(at index: Int) -> Element?
    {
        let element : Element? = self.indices.contains(index) ? self[index] : nil
        return element
    }
}
