import UIKit
import CoreLocation

class DebugView: UIView
{
    //MARK: Fields
    private let dateTimeFormatter = DateFormatter()
    private var recentLocationUpdates = [CLLocation]()
    private var list: UILabel!
    
    //MARK: Initializers
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        dateTimeFormatter.dateFormat = "HH:mm:ss"
        
        backgroundColor = UIColor.green.withAlphaComponent(0.25)
        
        let listFrame = CGRect(x: 5, y: 5, width: self.frame.width - 5, height: self.frame.height - 5)
        
        list = UILabel(frame: listFrame)
        list.text = "..."
        list.lineBreakMode = .byClipping
        list.numberOfLines = 0
        list.sizeToFit()
        list.font = list.font.withSize(8)
        
        addSubview(list)
    }
    
    //MARK: Methods
    func onNewLocation(_ location: CLLocation)
    {
        if recentLocationUpdates.count > 20
        {
            recentLocationUpdates.remove(at: 0)
        }
        
        recentLocationUpdates.append(location)
        
        updateList()
    }
    
    func updateList()
    {
        var text = ""
        
        recentLocationUpdates.reversed().forEach(
            {
                location in text += "\(dateTimeFormatter.string(from: location.timestamp)):"
                    + " <\(location.coordinate.latitude),\(location.coordinate.longitude)>"
                    + " ~\(Int(max(location.horizontalAccuracy, location.verticalAccuracy)))m"
                    + " (\(round(location.speed*10)/10.0)m/s)\n"
            }
        )
        
        list.frame = CGRect(x: 5, y: 5, width: self.frame.width - 5, height: self.frame.height - 5)
        list.text = text
        list.sizeToFit()
    }

}
