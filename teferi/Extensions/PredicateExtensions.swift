import CoreData

extension Predicate
{
    func convertToNSPredicate() -> NSPredicate
    {
        let predicate = NSPredicate(format: self.format, argumentArray: self.parameters)
        return predicate
    }
}
